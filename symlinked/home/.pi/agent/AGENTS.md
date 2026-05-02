# Global agent instructions

These directives apply to every pi session and to every subagent the orchestrator spawns.

## Artifact storage

Any file an agent (or subagent, or chain step) writes that is *not* a deliverable the user explicitly asked for in their working tree — research notes, scout/context-builder outputs, plans, handoffs, progress trackers, scratch summaries, screenshots, generated diagrams, evaluation logs — **must** live under `.pi/artifacts/` relative to the project root (i.e. the cwd at session start).

Concretely:

- `subagent(...)` calls that pass an `output` path: prefix it with `.pi/artifacts/`. Examples:
  - `output: ".pi/artifacts/research.md"` (single agent)
  - `output: ".pi/artifacts/parallel-review/correctness.md"` (parallel fanout)
  - `output: ".pi/artifacts/handoff/final-handoff-plan.md"` (chains)
- Tasks that produce ad-hoc files (`progress.md`, `context.md`, `scratch.md`, etc.) without an explicit `output:` parameter: instruct the child agent in the task string to write under `.pi/artifacts/<descriptive-name>.md`.
- `progress: true` / chain `chainDir`: leave these alone — they already live in a temp dir managed by pi.
- `mkdir -p .pi/artifacts` before the first delegation if the directory doesn't exist.

`.pi/artifacts/` is gitignored globally on this machine, so artifacts never accidentally land in commits and are easy to wipe (`rm -rf .pi/artifacts`) when finished.

If the user explicitly asks for an artifact to live somewhere else (e.g. `docs/research-foo.md`), follow their instruction — this rule covers the default, not user overrides.
