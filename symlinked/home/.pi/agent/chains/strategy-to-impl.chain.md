---
name: strategy-to-impl
description: Strategy → implementation plan → implement → review. Chef-de-cuisine runs stages 1-3 (with sous-chef AI review loops + human-gate via contact_supervisor on stages 1 and 2). Aboyeur runs stage 4 (review + refire loop with conditional health-inspector and patissier). Implementers are chefs-de-partie in worktrees.
---

## chef-de-cuisine

Stage 1 — MENU mode (strategy onepager).

Receive the kickoff material below. Write a one-page, narrative,
ELI5-style technical strategy onepager to
`./.pi/artifacts/strategy.md`. Problem-first prose, plain language,
key tradeoffs, explicit non-goals. No task graph in this stage —
that's the prep list, not the menu.

Then drive the strategy AI review loop:
- Classify complexity: simple → 1 sous-chef; complex → 3 sous-chefs in
  parallel with distinct angles (tech-feasibility, business-risk-and-scope,
  simplicity-and-ELI5-clarity).
- Call `subagent({tasks:[...], context:"fresh"})`, one task per
  sous-chef, each receiving the current strategy.md path and its angle.
- Reconcile all verdicts (BLOCKING / NON-BLOCKING / AGREE) in ONE
  rewrite of strategy.md per wave.
- You — the chef — decide when AI feedback has plateaued (waves
  repeating themselves, no new BLOCKING moving you).
- Hard cap 5 AI waves per human-gate iteration.

[HUMAN GATE]
When the AI plateau is reached, call `contact_supervisor` with:
  reason: "need_decision"
  message: a summary of waves run, the current plateau reason, the
  artifact path (`./.pi/artifacts/strategy.md`), and the reply contract:
    APPROVE | REVISE: <feedback> | MORE_WAVES: <N> [angles=...] | DENY: <reason>

On reply:
- APPROVE → output the audit trail and finish your turn.
- REVISE: <feedback> → incorporate the feedback in one rewrite of
  strategy.md (optionally fan out one more sous-chef wave first if the
  feedback opens a new angle), then call contact_supervisor again.
- MORE_WAVES: <N> [angles=...] → fan out N additional sous-chefs
  (parsing angles if given), reconcile in one rewrite, then call
  contact_supervisor again.
- DENY: <reason> → emit a turn-final summary explaining the deny
  reason and exit with non-zero status (chain step fails).

No cap on human-gate iterations — the human controls the loop.
[/HUMAN GATE]

Output the wave-by-wave audit trail (AI waves + human-gate iterations,
final disposition) as your turn-final response.

Kickoff material:
{task}

## chef-de-cuisine
reads: .pi/artifacts/strategy.md

Stage 2 — PREP-LIST mode (the implementation plan).

Read the agreed menu at `./.pi/artifacts/strategy.md`. Write the
implementation plan (your prep list) to
`./.pi/artifacts/implementation-plan.md`: numbered tasks (T1, T2, ...),
dependencies (`blockedBy: [T#]`), lane labels, parallel_with hints,
acceptance criteria, validation commands.

Then drive the implementation-plan AI review loop:
- Call `sous-chef` ONCE per wave (single reviewer, not parallel) with
  angle "implementation-plan critique" — testability, dependency
  honesty, exit-criteria reachability, tooling-exists checks.
- Reconcile verdict, rewrite implementation-plan.md in place.
- You decide AI plateau. Hard cap 5 AI waves.

**No human gate at this stage.** The strategy was the human-judgment
moment; the implementation plan is mechanical fallout. After the AI
plateau, output the audit trail and exit — do **not** call
`contact_supervisor`. The next chain step (SERVICE) will spawn
automatically.

(`contact_supervisor` is reserved here for stage 3 batch-failure
escalations, not for plan review.)

Output the final implementation-plan summary (AI waves run,
plateau reason, task list, lane distribution) as your turn-final
response.

Strategy review summary from previous step: {previous}

## chef-de-cuisine
reads: .pi/artifacts/implementation-plan.md

Stage 3 — SERVICE mode (execute the prep list).

Read `./.pi/artifacts/implementation-plan.md`. Derive ordered batches
that respect `blockedBy` dependencies. Within each batch, fan out N
parallel `chef-de-partie` implementers via
`subagent({tasks:[...], worktree:true})`, one task per parallel-safe
plan task. Each implementer task prompt must include: focused scope,
acceptance criteria (verbatim from the plan), validation commands
(verbatim from the plan), file/lane scope, escalation rule
(`contact_supervisor` on unapproved decisions).

After each batch:
- Aggregate implementer outputs (changed files by lane, validation
  results, any escalations).
- On any failure (non-zero return or "no edits made" report), escalate
  via `contact_supervisor` and stop. Do not silently advance to the
  next batch.
- On success, advance to the next batch.

Continue until all batches pass. Output the implementation summary
(batches run, tasks completed, files changed by lane, overall
validation, escalation count) as your turn-final response.

Implementation-plan review summary from previous step: {previous}

## aboyeur

Stage 4 — THE PASS (review + refire loop).

Drive the code-review-and-refire loop on the implementation diff
produced by the previous step. Inspect directly via `git diff` and
file reads. Nothing leaves the kitchen without crossing your eye.

Wave protocol:
1. Identify the base ref (default `origin/main`; check {previous} for
   any explicit base override).
2. Classify diff complexity. Simple → 1 sous-chef with combined
   angles; complex → 3 sous-chefs in parallel
   (correctness/regressions, tests/validation, simplicity/maintainability).
3. Add `health-inspector` if the diff touches auth, data persistence,
   HTTP endpoints, queues, file I/O, third-party calls, or
   security-relevant configuration.
4. Add `patissier` if a design spec path was supplied (in {previous},
   in `./.pi/artifacts/strategy.md`, or in
   `./.pi/artifacts/implementation-plan.md`).
5. Call `subagent({tasks:[...], context:"fresh"})` with each
   reviewer; collect verdicts.
6. If any BLOCKING findings: refire via
   `subagent({agent:"chef-de-partie", task:"<fix-meta-prompt with file:line refs>", worktree:true})`.
   Wait for chef-de-partie to return.
7. Re-run the wave on the updated diff.
8. You — the receiver of the fix-cycle feedback — decide when feedback
   has plateaued (no new BLOCKING after fixes applied). Hard cap 5
   waves. On hit-cap, emit `STATUS: HIT_WAVE_CAP` and exit non-zero.

Write the final review summary to
`./.pi/artifacts/final-review-summary.md`. Include wave-by-wave
findings, applied-fix log (refires), final BLOCKING/NON-BLOCKING/AGREE
counts, plateau call, and recommended next steps.

Implementation summary from previous step: {previous}
