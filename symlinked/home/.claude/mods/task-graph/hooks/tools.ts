import { atom, read } from 'claude-code'
import type { EngineInterface, On } from 'claude-code'

import { addTask, cancel, claim, complete, describe, describeTask, emptyGraph, progress, updateTask } from './store'
import type { Result } from './store'
import { highlight, mutate, seen } from './state'

const graph = atom({ plugin: 'task-graph', key: 'graph' } as const, emptyGraph())

// The tools Claude works the graph through. Every answer carries the graph's
// current state, so reading a result is consulting the latest plan.

const TOOLS = [
  {
    name: 'tg_next',
    description:
      'Read the shared task graph and the eligible queue, in the order the human wants. Call this before choosing what to work on next: the human may have canceled, edited or reprioritized tasks. This graph is the shared, authoritative plan: never work on a canceled task, claim (tg_claim) before working, add discovered subtasks with tg_add, and when a task changed while you worked on it, re-read it and meet its current acceptance criteria before tg_complete.',
    inputSchema: { type: 'object', properties: {} },
  },
  {
    name: 'tg_get',
    description: 'Read one task in full: description, acceptance criteria, revision, progress notes.',
    inputSchema: { type: 'object', properties: { id: { type: 'string' } }, required: ['id'] },
  },
  {
    name: 'tg_claim',
    description:
      'Claim a task before working on it; it becomes HEAD. Refused for a canceled or completed task, or when `revision` no longer matches.',
    inputSchema: {
      type: 'object',
      properties: { id: { type: 'string' }, revision: { type: 'number' } },
      required: ['id'],
    },
  },
  {
    name: 'tg_add',
    description:
      'Add a task, or a subtask with `parentId`, as you discover work. `blockedBy` lists task ids that must finish first.',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string' },
        parentId: { type: 'string' },
        description: { type: 'string' },
        acceptance: { type: 'string' },
        blockedBy: { type: 'array', items: { type: 'string' } },
      },
      required: ['title'],
    },
  },
  {
    name: 'tg_update',
    description: "Edit a task's title, description, acceptance criteria or blockers. Pass the `revision` you read.",
    inputSchema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        revision: { type: 'number' },
        title: { type: 'string' },
        description: { type: 'string' },
        acceptance: { type: 'string' },
        blockedBy: { type: 'array', items: { type: 'string' } },
      },
      required: ['id'],
    },
  },
  {
    name: 'tg_progress',
    description: 'Record a short progress note on a task the human can read.',
    inputSchema: {
      type: 'object',
      properties: { id: { type: 'string' }, note: { type: 'string' } },
      required: ['id', 'note'],
    },
  },
  {
    name: 'tg_complete',
    description:
      'Mark a task completed. Refused when the human changed it since you claimed it: re-read it, meet the current acceptance criteria, then pass its current `revision`.',
    inputSchema: {
      type: 'object',
      properties: { id: { type: 'string' }, revision: { type: 'number' } },
      required: ['id'],
    },
  },
  {
    name: 'tg_cancel',
    description: 'Cancel a task that is no longer needed. It stays in the graph as canceled.',
    inputSchema: { type: 'object', properties: { id: { type: 'string' } }, required: ['id'] },
  },
] as const

export const TOOL_PREFIX = 'mcp__task-graph__'

const str = (value: unknown): string | undefined => (typeof value === 'string' ? value : undefined)
const num = (value: unknown): number | undefined => (typeof value === 'number' ? value : undefined)
const strs = (value: unknown): string[] | undefined =>
  Array.isArray(value) ? value.filter((one): one is string => typeof one === 'string') : undefined

type Args = Record<string, unknown>

async function answer($: EngineInterface, result: Result, lead: (r: Extract<Result, { ok: true }>) => string) {
  if (!result.ok) return { deny: `${result.error}\n\n${describe(await read($, graph))}` }

  return { result: `${lead(result)}\n\n${describe(result.graph)}` }
}

export async function registerTools($: EngineInterface): Promise<void> {
  for (const tool of TOOLS) {
    await $.tool.register({ ...tool, inputSchema: { ...tool.inputSchema }, isDeferred: false })
  }
}

export const serveTools = (on: On): void => {
  on('tool.call', { tool: 'mcp__task-graph__tg_next' }, async $ => {
    await seen($)

    return { result: describe(await read($, graph)) }
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_get' }, async ($, e) => {
    const value = await read($, graph)
    const task = value.tasks[str((e as Args).id) ?? '']
    if (task === undefined) return { deny: `No task ${String((e as Args).id)}.\n\n${describe(value)}` }

    return { result: describeTask(task, value) }
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_claim' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const result = await mutate($, value => claim(value, str(args.id) ?? '', now, num(args.revision)), {
      seenByClaude: true,
    })

    return answer($, result, ok => `Claimed. HEAD is now:\n${describeTask(ok.task, ok.graph)}`)
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_add' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const result = await mutate(
      $,
      value =>
        addTask(
          value,
          {
            title: str(args.title) ?? '',
            parentId: str(args.parentId) ?? null,
            description: str(args.description),
            acceptance: str(args.acceptance),
            blockedBy: strs(args.blockedBy),
            createdBy: 'claude',
          },
          now,
        ),
      { seenByClaude: true },
    )
    if (result.ok) await highlight($, result.task.id)

    return answer($, result, ok => `Added ${ok.task.id}.`)
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_update' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const patch = {
      ...(str(args.title) === undefined ? {} : { title: str(args.title)! }),
      ...(str(args.description) === undefined ? {} : { description: str(args.description)! }),
      ...(str(args.acceptance) === undefined ? {} : { acceptance: str(args.acceptance)! }),
      ...(strs(args.blockedBy) === undefined ? {} : { blockedBy: strs(args.blockedBy)! }),
    }
    const result = await mutate($, value => updateTask(value, str(args.id) ?? '', patch, 'claude', now, num(args.revision)), {
      seenByClaude: true,
    })

    return answer($, result, ok => `Updated ${ok.task.id} to revision ${ok.task.revision}.`)
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_progress' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const result = await mutate($, value => progress(value, str(args.id) ?? '', str(args.note) ?? '', now))

    return answer($, result, ok => `Noted on ${ok.task.id}.`)
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_complete' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const result = await mutate($, value => complete(value, str(args.id) ?? '', 'claude', now, num(args.revision)), {
      seenByClaude: true,
    })

    return answer($, result, ok => `Completed ${ok.task.id}. Call tg_next to pick the next task.`)
  })

  on('tool.call', { tool: 'mcp__task-graph__tg_cancel' }, async ($, e) => {
    const args = e as Args
    const now = await $.clock.now()
    const result = await mutate($, value => cancel(value, str(args.id) ?? '', 'claude', now), { seenByClaude: true })

    return answer($, result, ok => `Canceled ${ok.task.id}.`)
  })
}

