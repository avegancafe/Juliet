import { expect, mock, test } from 'claude-code/testing'
import type { On } from 'claude-code'

const PANE = {
  plugin: 'task-graph',
  component: 'Pane',
  requestId: 'task-graph',
  props: {
    title: 'Tasks',
    isFocused: true,
    bodyColumns: 80,
    placement: 'dock',
    scroll: { offset: 0, bodyRows: 40 },
    view: {},
  },
} as const

const SURFACES = ['terminal', 'desktop'] as const

/** The engine beneath the plugin: just enough of it to start a session. */
const engine = (on: On, stored: Record<string, unknown> = {}) => {
  const clock = mock.clock(on, { now: 1_000 })
  mock.store(on, stored)
  on('command.register', () => ({ value: { command: 'task-graph' } }))
  on('tool.register', (_, e) => ({ value: { tool: `mcp__task-graph__${e.name}` } }))
  on('ui.open', () => ({ value: { isPlaced: true } }))
  on('ui.focus', () => ({}))
  on('ui.status', () => ({ value: undefined }))
  on('ui.scroll', () => ({}))
  on('session.root', () => ({ value: '/repo' }))
  on('session.id', () => ({ value: 'session-a' }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('tool.call', () => ({ result: 'ran' }))

  return clock
}

const tg = async ($: any, name: string, args: Record<string, unknown> = {}) =>
  $.tool.call({ tool: `mcp__task-graph__${name}`, ...args }) as Promise<{ result?: string; deny?: string }>

const plan = async ($: any) => {
  await $.session.start({ cwd: '/repo', surface: 'desktop', isInteractive: true })
  await tg($, 'tg_add', { title: 'Design schema' })
  await tg($, 'tg_add', { title: 'Backend implementation' })
  await tg($, 'tg_add', { title: 'Integration tests' })
}

test('1: a three-task plan renders as graph rows', async ($, on) => {
  engine(on)
  await plan($)
  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...PANE, surface })
    for (const id of ['t1', 't2', 't3']) expect(await ui.find({ key: `row-${id}` })).toBeDefined()
    expect((await ui.find({ key: 'row-t2' }))?.text).toContain('Backend implementation')
    await ui.unmount()
  }
})

test('2: an edit in the modal persists', async ($, on) => {
  engine(on)
  await plan($)
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  await ui.press({ key: 'row-t1' })
  await ui.press({ key: 'act-edit-t1' })
  await ui.input({ key: 'm-acc', text: 'schema reviewed', kind: 'change' })
  await ui.press({ key: 'm-save' })
  await ui.press({ key: 'm-close' })
  const got = await tg($, 'tg_get', { id: 't1' })
  expect(got.result).toContain('Acceptance criteria: schema reviewed')
  await ui.unmount()
})

test('3: a canceled task is never claimed', async ($, on) => {
  engine(on)
  await plan($)
  const ui = await $.ui.mount({ ...PANE, surface: 'terminal' })
  await ui.press({ key: 'row-t2' })
  await ui.press({ key: 'act-cancel-t2' })
  const next = await tg($, 'tg_next')
  expect(next.result).toContain('Eligible next, in order: t1, t3')
  const claimed = await tg($, 'tg_claim', { id: 't2' })
  expect(claimed.deny).toContain('canceled')
  // Hidden by default; the top row brings it back, struck through.
  expect(await ui.find({ key: 'row-t2' })).toBeUndefined()
  await ui.press({ key: 'toggle-canceled' })
  expect((await ui.find({ key: 'row-t2' }))?.text).toContain('Backend implementation')
  await ui.press({ key: 'toggle-canceled' })
  expect(await ui.find({ key: 'row-t2' })).toBeUndefined()
  await ui.unmount()
})

test('4: "work on this next" reorders the queue', async ($, on) => {
  engine(on)
  await plan($)
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  await ui.press({ key: 'row-t3' })
  await ui.press({ key: 'act-next-t3' })
  expect((await tg($, 'tg_next')).result).toContain('Eligible next, in order: t3, t1, t2')
  await ui.unmount()
})

test('5: a subtask arrives highlighted without moving the selection', async ($, on) => {
  const clock = engine(on)
  await plan($)
  const ui = await $.ui.mount({ ...PANE, surface: 'terminal' })
  await ui.press({ key: 'row-t2' })
  await tg($, 'tg_add', { title: 'Create models', parentId: 't2' })
  expect((await ui.find({ key: 'row-t4' }))?.text).toContain('new')
  const selected = await ui.findAll({ type: 'Text', text: /Backend implementation/ })
  expect(selected.some(one => one.props.inverse === true)).toBe(true)
  await clock.advance(10_000)
  expect((await ui.find({ key: 'row-t4' }))?.text).not.toContain('new')
  await ui.unmount()
})

test('6: a completed task stays visible and expanded', async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_add', { title: 'Create models', parentId: 't2' })
  await tg($, 'tg_claim', { id: 't4' })
  await tg($, 'tg_complete', { id: 't4' })
  await tg($, 'tg_claim', { id: 't2' })
  await tg($, 'tg_complete', { id: 't2' })
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  expect((await ui.find({ key: 'line-t2' }))?.text).toContain('✓')
  expect((await ui.find({ key: 'row-t4' }))?.text).toContain('Create models')
  await ui.unmount()
})

test('7: a change underneath an open draft shows a conflict and keeps the draft', async ($, on) => {
  engine(on)
  await plan($)
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  await ui.press({ key: 'row-t1' })
  await ui.press({ key: 'act-edit-t1' })
  await ui.input({ key: 'm-title', text: 'Design the schema (mine)', kind: 'change' })
  await tg($, 'tg_update', { id: 't1', title: 'Design schema v2' })
  await ui.press({ key: 'm-save' })
  expect(await ui.find({ type: 'Text', text: /Changed while you edited/ })).toBeDefined()
  expect((await ui.find({ key: 'm-title' }))?.props.value).toBe('Design the schema (mine)')
  await ui.press({ key: 'm-mine' })
  expect((await tg($, 'tg_get', { id: 't1' })).result).toContain('Design the schema (mine)')
  await ui.unmount()
})

test('8: tasks draw alike whatever made them; provenance is in the drawer', async ($, on) => {
  engine(on)
  await plan($)
  await $.tool.call({ tool: 'TaskCreate', subject: 'Write docs', description: '' })
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  const native = await ui.find({ key: 'row-t4' })
  const graph = await ui.find({ key: 'row-t3' })
  expect(native?.text).toContain('Write docs')
  expect(native?.type).toBe(graph?.type)
  expect(native?.props.plain).toBe(graph?.props.plain)
  await ui.press({ key: 'row-t4' })
  expect(await ui.find({ type: 'Text', text: /created by claude/ })).toBeDefined()
  expect(await ui.find({ key: 'a' })).toBeUndefined()
  expect(await ui.find({ key: 'act-sub-t4' })).toBeUndefined()
  await ui.unmount()
})

test('native TaskCreate and TaskUpdate write to the same graph', async ($, on) => {
  engine(on)
  await plan($)
  const created = (await $.tool.call({ tool: 'TaskCreate', subject: 'Native task', description: '' })) as { result?: { task: { id: string } } }
  expect(created.result?.task.id).toBe('t4')
  await $.tool.call({ tool: 'TaskUpdate', taskId: 't4', status: 'in_progress' })
  expect((await tg($, 'tg_next')).result).toContain('t4 [in_progress]')
  const ui = await $.ui.mount({ ...PANE, surface: 'terminal' })
  await ui.press({ key: 'row-t1' })
  await ui.press({ key: 'act-cancel-t1' })
  const refused = (await $.tool.call({ tool: 'TaskUpdate', taskId: 't1', status: 'in_progress' })) as { deny?: string }
  expect(refused.deny).toContain('canceled')
  await ui.unmount()
})

test('a human edit reaches Claude with its next tool result', async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_next')
  const ui = await $.ui.mount({ ...PANE, surface: 'terminal' })
  await ui.press({ key: 'row-t1' })
  await ui.press({ key: 'act-cancel-t1' })
  const ran = (await $.tool.call({ tool: 'Bash', command: 'ls' })) as { context?: string[] }
  expect(ran.context?.join('\n')).toContain('canceled "Design schema"')
  const again = (await $.tool.call({ tool: 'Bash', command: 'ls' })) as { context?: string[] }
  expect(again.context).toBeUndefined()
  await ui.unmount()
})

test('a native TaskList tells Claude what the human changed', async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_next')
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  await ui.press({ key: 'row-t2' })
  await ui.press({ key: 'act-cancel-t2' })
  const listed = (await $.tool.call({ tool: 'TaskList' })) as { context?: string[] }
  expect(listed.context?.join('\n')).toContain('canceled "Backend implementation"')
  await ui.unmount()
})

test("Claude's own edit never makes its claim stale; a human edit does", async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_claim', { id: 't1' })
  await tg($, 'tg_update', { id: 't1', description: 'tables and indexes' })
  expect((await tg($, 'tg_complete', { id: 't1' })).result).toContain('Completed t1')
  await $.tool.call({ tool: 'TaskUpdate', taskId: 't2', subject: 'Backend API', status: 'in_progress' })
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  await ui.press({ key: 'row-t2' })
  await ui.press({ key: 'act-edit-t2' })
  await ui.input({ key: 'm-acc', text: 'all endpoints tested', kind: 'change' })
  await ui.press({ key: 'm-save' })
  const refused = await tg($, 'tg_complete', { id: 't2' })
  expect(refused.deny).toContain('changed since you claimed it')
  await ui.unmount()
})

test('a click on a row opens its drawer of actions; a second click closes it', async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_add', { title: 'Create models', parentId: 't2' })
  for (const surface of SURFACES) {
    const ui = await $.ui.mount({ ...PANE, surface })
    await ui.press({ key: 'row-t2' })
    for (const action of ['edit', 'next', 'done', 'cancel', 'up', 'down', 'fold']) {
      expect(await ui.find({ key: `act-${action}-t2` })).toBeDefined()
    }
    expect(await ui.find({ type: 'Text', text: /created by claude/ })).toBeDefined()
    await ui.press({ key: 'act-fold-t2' })
    expect(await ui.find({ key: 'row-t4' })).toBeUndefined()
    expect(await ui.find({ key: 'act-fold-t2' })).toBeDefined()
    await ui.press({ key: 'act-fold-t2' })
    await ui.press({ key: 'row-t2' })
    expect(await ui.find({ key: 'act-edit-t2' })).toBeUndefined()
    expect(await ui.find({ key: 'row-t4' })).toBeDefined()
    await ui.unmount()
  }
})

test('the graph is drawn in the monospaced face, rails and titles alike', async ($, on) => {
  engine(on)
  await plan($)
  await tg($, 'tg_add', { title: 'Create models', parentId: 't2' })
  const ui = await $.ui.mount({ ...PANE, surface: 'desktop' })
  // With no drawer or modal open, every Text in the pane belongs to a graph row.
  const texts = await ui.findAll({ type: 'Text' })
  expect(texts.length).toBeGreaterThan(4)
  expect(texts.every(one => one.props.mono === true)).toBe(true)
  expect((await ui.find({ key: 'line-t4' }))?.text).toContain('└─ ○ Create models')
  await ui.unmount()
})

test('each session keeps its own graph; another session\'s and the old shared one stay out', async ($, on) => {
  const other = (title: string) => ({
    tasks: { t1: { id: 't1', parentId: null, title, description: '', acceptance: '', status: 'pending', order: 0, blockedBy: [], createdBy: 'claude', revision: 1, createdAt: 0, updatedAt: 0, notes: [] } },
    rev: 1, nextId: 2, claim: null, nextUp: [], changes: [], claudeSeen: 1,
  })
  engine(on, {
    'graph:/repo': { root: '/repo', graph: other('Old shared task'), savedAt: 1_000 },
    'graph:session:session-b': { root: '/repo', sessionId: 'session-b', graph: other('Other session task'), savedAt: 1_000 },
  })
  await $.session.start({ cwd: '/repo', surface: 'desktop', isInteractive: true })
  const next = (await tg($, 'tg_next')).result ?? ''
  expect(next).not.toContain('Old shared task')
  expect(next).not.toContain('Other session task')
})

test('a restarted session picks its own graph back up', async ($, on) => {
  engine(on, {
    'graph:session:session-a': {
      root: '/repo', sessionId: 'session-a', savedAt: 1_000,
      graph: {
        tasks: { t1: { id: 't1', parentId: null, title: 'Mine from before', description: '', acceptance: '', status: 'pending', order: 0, blockedBy: [], createdBy: 'claude', revision: 1, createdAt: 0, updatedAt: 0, notes: [] } },
        rev: 1, nextId: 2, claim: null, nextUp: [], changes: [], claudeSeen: 1,
      },
    },
  })
  await $.session.start({ cwd: '/repo', surface: 'desktop', isInteractive: true })
  expect((await tg($, 'tg_next')).result).toContain('Mine from before')
})
