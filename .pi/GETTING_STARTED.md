# Getting Started with pi (Juliet edition)

A quick orientation for [pi](https://github.com/badlogic/pi-mono) as configured in Juliet. Covers the extensions Juliet ships with, the slash commands and keys you'll actually use day-to-day, and orchestration patterns that don't show up in the help screen.

Pi's own first-party docs live under the `pi-coding-agent` package in `~/.nodenv/`. Pi can also explain itself — just ask the agent.

---

## What's installed

**Skills**
- `pi-intercom`
- `pi-subagents`
- `plannotator-compound`

**Prompt templates**
- `/chef` — run the brigade strategy-to-implementation chain
- `/runner` — bridge a chef-de-cuisine human gate through Plannotator
- `/gather-context-and-clarify`
- `/parallel-cleanup`
- `/parallel-context-build`
- `/parallel-handoff-plan`
- `/parallel-research`
- `/parallel-review`

**User agents (kitchen brigade)**
- `chef-de-cuisine`, `sous-chef`, `aboyeur`, `chef-de-partie`, `health-inspector`, `patissier`

**Saved chains**
- `strategy-to-impl` — strategy → plan → implement → review, with AI critique waves and human gates

**Extensions**
- `@plannotator/pi-extension`
- `pi-ask-user`
- `pi-btw`
- `pi-intercom`
- `pi-mcp-adapter`
- `pi-subagents`

**Defaults**
- Theme: `bamboo`
- Model: `claude-opus-4-7` · thinking: `xhigh`
- Available models: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`

All of this is wired up in Juliet's symlinked `~/.pi/agent/settings.json`. You don't need to install anything — `juliet-bootstrap` handles it.

---

## First 5 minutes

```bash
pi                  # start a session in the cwd
ctrl+o              # show loaded resources banner
/                   # browse all slash commands
ctrl+c / ctrl+d     # exit
escape              # interrupt the agent mid-turn
```

A few useful things to try right away:

- Ask the agent to explain itself: *"What can you do that a normal Claude session can't?"*
- Run `/subagents-doctor` to confirm the subagent + intercom bridges are healthy.
- Run `/agents` to see the 8 builtin agents (scout, planner, worker, reviewer, oracle, researcher, context-builder, delegate).
- Run `/mcp` to see configured MCP servers (none until you set them up).

---

## Extensions cheat sheet

### `pi-subagents` — delegation & orchestration

The big one. Lets the parent session delegate work to child agents without burning the main thread's context. Children can run sequentially, in parallel, async/background, with fresh or forked context.

| Command | What it does |
|---|---|
| `/run <agent> <task>` | Launch one agent. Add `[model=...]` or `[thinking=high]` inline. |
| `/chain` | Multi-step pipeline (each step's output feeds `{previous}`). |
| `/parallel` | Run several agents concurrently. |
| `/agents` | TUI manager for builtin/user/project agents and overrides. |
| `/run-chain <name>` | Launch a saved `.chain.md` workflow. |
| `/subagents-status` | Inspect active and recent async runs. |
| `/subagents-doctor` | Diagnose discovery, async paths, intercom bridge state. |

**Builtin agents** (all inherit your default model unless overridden):

- `scout` — fast codebase recon
- `researcher` — autonomous web research, returns a brief
- `context-builder` — structured handoff doc + meta-prompt
- `planner` — implementation plan from context (forks parent session)
- `worker` — single-writer implementer (forks parent session)
- `reviewer` — fresh-context review specialist
- `oracle` — high-context advisory review (forks parent session)
- `delegate` — generic lightweight delegate

**Prompt template shortcuts** (multi-agent recipes):

- `/chef` — launch the kitchen-brigade `strategy-to-impl` chain end-to-end (see *The kitchen brigade* below)
- `/runner` — bridge an open chef-de-cuisine human gate through Plannotator's annotation UI
- `/parallel-review` — fresh-context reviewers with distinct angles, then synthesize
- `/parallel-research` — `researcher` for external evidence + `scout` for local context
- `/parallel-context-build` — parallel `context-builder` passes producing a planning handoff
- `/parallel-handoff-plan` — research plus local context, then synthesis into an implementation-ready handoff
- `/gather-context-and-clarify` — recon, then ask you the missing questions
- `/parallel-cleanup` — adversarial deslop + verbosity review of the current diff

**The mental model**: one decision-maker (the parent) plus children for research, review, and implementation. Big artifacts get written under `.pi/artifacts/` so they don't bloat the parent's context.

### `pi-intercom` — bidirectional session messaging

Direct 1:1 messaging between pi sessions on the same machine. Two reasons it's useful:

1. **You** running multiple pi sessions and wanting to ferry context between them.
2. **Subagents** automatically getting a `contact_supervisor` tool that lets them ping the parent for decisions or progress updates without the parent having to poll.

| Action | What it does |
|---|---|
| `Alt+M` or `/intercom` | Open the session-picker overlay. |
| `intercom({action:"list"})` | Agent lists other connected pi sessions. |
| `intercom({action:"send", to, message})` | Agent sends a message. |
| `intercom({action:"ask", to, message})` | Agent sends and waits for a reply. |
| `intercom({action:"reply", message})` | Reply to a pending ask. |
| `contact_supervisor({reason, message})` | (children only) Ping the parent. Two reasons: `need_decision` (blocking) and `progress_update` (non-blocking). |

When both extensions are loaded, the bridge auto-wires itself. Async children then push completion notifications back through intercom, so you don't have to keep running `/subagents-status` manually.

### `pi-btw` — parallel side conversations

The `/btw` command opens a real pi sub-session in an overlay. You can keep talking to it while the main agent is busy, and the side thread stays out of the main agent's context unless you choose to inject it.

| Command | What it does |
|---|---|
| `/btw <question>` | Continue or start the BTW thread. |
| `/btw --save <q>` | Same, but also save this exchange as a visible session note. |
| `/btw:tangent <q>` | Side thread that does *not* inherit the main session context. |
| `/btw:new <q>` | Start a fresh BTW thread. |
| `/btw:model <provider> <model> [api]` | Override model for BTW only. |
| `/btw:thinking low\|medium\|high` | Override thinking level for BTW only. |
| `/btw:inject <prompt>` | Push BTW's accumulated context back into the main thread. |
| `/btw:summarize <prompt>` | Same, but as a summary instead of full thread. |
| `/btw:clear` | Drop BTW state. |
| `Alt+/` | Toggle focus between BTW overlay and main editor. |
| `Ctrl+Alt+W` | Fallback focus toggle if `Alt+/` doesn't work. |
| `Esc` | Dismiss BTW (when focused). |

Good for: "while you keep working on X, can you also tell me what file Y does?"

### `@plannotator/pi-extension` — visual plan review

Plan-mode workflow with a browser UI for reviewing and annotating agent plans before execution. Also exposes a generic markdown annotator that the brigade workflow uses for human gates.

| Command | What it does |
|---|---|
| `pi --plan` | Start pi in plan mode. |
| `/plannotator [path]` | Toggle plan mode mid-session, optionally pointing at a file. |
| `/plannotator-annotate <file.md>` | Open any markdown file in the annotation UI. Used by `/runner` for strategy/plan review. |
| `/plannotator-review` | Open the current git diff in the code-review annotator. |
| `/plannotator-last` | Annotate the agent's last response. |
| `Ctrl+Alt+P` | Toggle plan mode keybind. |

In plan mode, destructive commands are blocked and writes are limited to the plan file. The agent explores, writes a markdown checklist plan, then `plannotator_submit_plan` opens the review UI in your browser. You approve or annotate; execution follows the approved plan.

For non-plan-mode review (annotating any markdown file or diff), use the dedicated commands above. Annotated feedback is delivered back to the agent as a follow-up message — the brigade `/runner` workflow translates that feedback into chef-de-cuisine's reply contract automatically.

### `pi-ask-user` — interactive decision prompts

Gives the agent an `ask_user` tool for collecting structured decisions during a turn. Searchable single-select or multi-select option lists, optional freeform fallback, optional comment field, configurable overlay vs inline display.

| Surface | What it does |
|---|---|
| `ask_user({question, options, ...})` | Agent tool. Pauses the turn and shows a TUI picker. Returns the chosen option or freeform text. |
| `Alt+O` (during prompt) | Temporarily hide/show the overlay so you can read prior agent output. |

Shipped with an `ask-user` skill that nudges the agent to use it for high-stakes architectural choices, ambiguous requirements, or assumptions that would materially change implementation. The brigade `/runner` workflow uses this for the verb picker on denied gates.

### `pi-mcp-adapter` — MCP without context bloat

Standard MCP gives every server's tool definitions to the model up front — that can be 10k+ tokens per server. This adapter exposes one ~200-token proxy tool; the agent discovers MCP tools on-demand and only starts servers when they're actually used.

| Command | What it does |
|---|---|
| `/mcp` | Open the MCP panel. |
| `/mcp setup` | First-run wizard: imports `.mcp.json`, host configs (Cursor, Claude Code, Codex), or scaffolds new. |
| `pi-mcp-adapter init` | CLI equivalent for the setup flow. |

Configured servers live in `.mcp.json` (project) or `~/.config/mcp/mcp.json` (user). Pi-owned overrides go in `~/.pi/agent/mcp.json` or `.pi/mcp.json`.

---

## The orchestration patterns worth knowing

These are the workflows the prompt-template shortcuts encode. You can run them via the slash command or just describe what you want — the parent agent will pick the right shape.

**Clarify before doing.** For non-trivial work, the agent should run `scout` (and `researcher` if external docs matter), then ask you the unresolved questions before planning. That's `/gather-context-and-clarify`.

**Plan, then implement, then review.** The full sequence is:

```text
clarify → planner → worker → parallel reviewers (fresh) → fix worker
```

Reviewers run in fresh context with distinct angles (correctness, tests, simplicity). The parent synthesizes their feedback and launches one final `worker` to apply the fixes worth doing now.

**Big research with low context cost.** When you want the agent to study external docs *and* local code without dumping everything into the main thread, use `/parallel-research` or `/parallel-handoff-plan`. Children write findings to `.pi/artifacts/` and the parent gets a compact synthesis.

**Async background work.** When you want the agent to keep working *while* a child runs (e.g. running tests, doing deep research), launch the child with `async: true`. With `pi-intercom` active, the completion arrives as a push notification instead of needing manual polling.

**Advisory thread without losing context.** When you want a sanity check on inherited decisions (drift, unstated assumptions), use `oracle` — it forks the current session so it sees your conversation history but reasons in a separate thread.

**Strategy → implementation, brigade-style.** For larger work that needs explicit strategy + plan ratification before execution, see *The kitchen brigade* section below.

---

## The kitchen brigade

A kitchen-themed pipeline of user agents and a saved chain (`strategy-to-impl`) that takes a project request through four stages: write strategy, write implementation plan, implement in parallel, and review. Each stage 1–2 has both an AI critique loop *and* a human approval gate — so you ratify the strategy and the plan before any code gets written.

### The agents

| Role | What they do |
|---|---|
| `chef-de-cuisine` | Executive chef. Writes `strategy.md` (MENU mode), then `implementation-plan.md` (PREP-LIST), then runs the implementation pass (SERVICE). Modal across stages. |
| `sous-chef` | Adversarial reviewer. Steelmans the artifact, then critiques from a stated angle (tech-feasibility / business-risk / simplicity / etc.). Returns BLOCKING / NON-BLOCKING / AGREE. |
| `aboyeur` | Expediter at the pass. Drives the code-review-and-fix-refire loop on the resulting diff. Spawns parallel reviewers, conditionally adds health-inspector and patissier. |
| `chef-de-partie` | Focused implementer. TDD discipline, one ticket at a time, escalates ambiguity instead of guessing. Used both for fresh implementation and for fix refires. |
| `health-inspector` | Security auditor. OWASP Top 10 + general checks. Runs only on diffs that touch auth, data, or external surfaces. |
| `patissier` | Design-QA reviewer. Verifies UI fidelity against a provided design spec. Refuses to evaluate without a spec. |

All six live in `~/.pi/agent/agents/*.md`. Inspect or tweak with `/agents`.

### The chain (`strategy-to-impl`)

```
stage 1: chef-de-cuisine MENU      → strategy.md       → sous-chef waves → [HUMAN GATE]
stage 2: chef-de-cuisine PREP-LIST → implementation-plan.md → sous-chef     → [HUMAN GATE]
stage 3: chef-de-cuisine SERVICE   → chef-de-partie fan-out in worktrees per dependency batch
stage 4: aboyeur            → review + refire loop → final-review-summary.md
```

Artifacts land under `.pi/artifacts/`. Worktree isolation is mandatory in stage 3 — the chain enforces clean git state before that stage.

### Day-to-day commands

| Command | What it does |
|---|---|
| `/chef <kickoff>` | Launch the full chain on a PRD, transcript, or freeform request. Add `"in the background"` / `"async"` to launch unattended; add `"autopilot"` / `"no review"` to skip human gates. |
| `/runner` | When chef-de-cuisine pauses at a stage-1 or stage-2 human gate, type this to bridge the review through Plannotator's browser annotation UI. Auto-translates the result into the chain's reply contract. |

### How a human gate flows with `/runner`

1. `chef-de-cuisine` reaches the gate → posts a `contact_supervisor` ask in your terminal. The ask ends with `(Human shortcut: type /runner ...)`.
2. You type `/runner`. The runner agent finds the pending ask, extracts the artifact path, prints the exact `/plannotator-annotate <path>` line for you to paste, and stops.
3. You run `/plannotator-annotate <path>`. Browser opens. You annotate. Click Approve or Deny-with-feedback.
4. Plannotator delivers the result to the runner agent as a follow-up.
   - **Approved** → runner auto-sends `APPROVE` via `intercom reply`.
   - **Denied with feedback** → runner uses `ask_user` to prompt for the verb (REVISE / MORE_WAVES / DENY) and sends the formatted reply.
5. Chain advances or rewrites accordingly. No verb cap on human-gate iterations — you control when each gate ends.

### Reply contract (for typing the verb manually)

When you don't want the `/runner` workflow, reply directly to the gate:

| Verb | Effect |
|---|---|
| `APPROVE` | Chain advances to the next stage. |
| `REVISE: <feedback>` | chef-de-cuisine rewrites once with the feedback (optionally with one more sous-chef wave) and re-prompts the gate. |
| `MORE_WAVES: <N> [angles=tech,scope,...]` | chef-de-cuisine spawns N more sous-chefs, optionally with the named angles, then re-prompts. |
| `DENY: <reason>` | Chain step fails and chain stops. |

### Where things live

| Path | Purpose |
|---|---|
| `~/.pi/agent/chains/strategy-to-impl.chain.md` | The chain definition. |
| `~/.pi/agent/agents/*.md` | Brigade agent definitions. |
| `~/.pi/agent/prompts/chef.md`, `runner.md` | Slash-command bodies. |
| `.pi/artifacts/strategy.md`, `implementation-plan.md`, `final-review-summary.md` | Stage outputs. Persistent across stages; read from disk each iteration. |

---

## Conventions Juliet enforces

`~/.pi/agent/AGENTS.md` (Juliet-managed) sets one global rule for every pi session and subagent:

> Any file an agent writes that **isn't** an explicit user-requested deliverable goes under `.pi/artifacts/` relative to the project root.

That includes scout outputs, research briefs, plans, handoffs, progress logs, screenshots — anything scratch. `.pi/artifacts/` is gitignored globally on this machine, so it never ends up in commits. Wipe it any time with `rm -rf .pi/artifacts`.

Project-explicit deliverables — anywhere you asked the agent to put a file — still go where you asked.

---

## Useful settings knobs

Edit `~/.pi/agent/settings.json` (symlinked, so edits land in Juliet):

```json
{
  "defaultModel": "claude-opus-4-7",
  "defaultThinkingLevel": "xhigh",
  "subagents": {
    "agentOverrides": {
      "researcher": {
        "model": "anthropic/claude-sonnet-4-6",
        "thinking": "high"
      },
      "reviewer": { "thinking": "xhigh" }
    }
  }
}
```

Override builtin agents per-role rather than copying full agent files when you just want a model or thinking-level swap. The `/agents` TUI does this interactively too.

For project-specific overrides, drop a `.pi/settings.json` in the repo — it wins over user scope. Custom agents go in `.pi/agents/*.md`; saved chains go in `.pi/chains/*.chain.md`.

---

## When something feels off

| Symptom | Try |
|---|---|
| Subagents/chain features missing | `/subagents-doctor` |
| Async child not coming back | `/subagents-status` |
| Intercom messages not arriving | `/subagents-doctor` (check bridge: active) |
| MCP server not connecting | `/mcp` panel; check `.mcp.json` |
| Plannotator UI not opening | check default browser; try `/plannotator` again |
| Plan mode too restrictive | exit with `/plannotator` toggle |
| `/runner` says "no chef-de-cuisine gate is pending" | the chain isn't paused at a gate — check `/subagents-status` or rerun `/chef` |
| `/runner` finds an ask but it's not a gate | only stage-1/stage-2 human gates are bridged. Stage-3 escalations need a manual `intercom reply`. |

Pi can also debug itself — describe the symptom to the agent and it'll usually run the right diagnostic.

---

## Going deeper

- Pi's own docs: `~/.nodenv/versions/*/lib/node_modules/@mariozechner/pi-coding-agent/docs/`
- pi-subagents skill: `~/.nodenv/.../pi-subagents/skills/pi-subagents/SKILL.md`
- pi-intercom skill: `~/.nodenv/.../pi-intercom/skills/pi-intercom/SKILL.md`
- Each extension also ships a `README.md` next to its source

Or just ask the agent directly: *"how do I write a custom agent?"*, *"explain the pi-subagents skill"*, *"show me how to save a chain"*.
