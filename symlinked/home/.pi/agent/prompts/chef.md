---
argument-hint: <PRD, transcript, or kickoff transcript>
description: Run the brigade pi-subagents chain end-to-end on a PRD, transcript, or freeform request. Chef-de-cuisine drafts a narrative ELI5 strategy onepager and a numbered implementation plan — each gated by parallel sous-chef AI review waves + your APPROVE/REVISE/MORE_WAVES/DENY approval. Then chef-de-cuisine fans out chef-de-partie implementers in parallel git worktrees per dependency batch, and aboyeur runs the code-review-and-fix-refire loop with conditional health-inspector (security) and patissier (design QA). Add "in the background" / "async" to launch unattended; "autopilot" / "no review" to skip human gates. Artifacts land in `.pi/artifacts/`.
---

Run the saved pi-subagents chain `strategy-to-impl` on the kickoff material below. The chain takes a project request through four sequential stages run by the kitchen-brigade agents:

1. **chef-de-cuisine** (MENU mode) — writes `.pi/artifacts/strategy.md` (one-page narrative ELI5 strategy onepager), drives the AI review loop with `sous-chef` reviewers, then opens a human review gate via `contact_supervisor`.
2. **chef-de-cuisine** (PREP-LIST mode) — writes `.pi/artifacts/implementation-plan.md` (numbered tasks + dependencies + lane labels + acceptance criteria), drives a single-reviewer AI loop, then opens the same human gate.
3. **chef-de-cuisine** (SERVICE mode) — fans out N parallel `chef-de-partie` implementers per dependency batch in worktrees, validates each batch.
4. **aboyeur** — code review + fix-refire loop on the resulting diff, with parallel `sous-chef` angle reviewers (correctness / tests / simplicity), conditional `health-inspector` (when the diff touches auth/data/external surfaces), conditional `patissier` (when a design spec was supplied). Routes BLOCKING fixes back to `chef-de-partie`. Writes `.pi/artifacts/final-review-summary.md`.

## Pre-flight before launching

1. **Artifacts dir.** If `.pi/artifacts/` does not exist in the current cwd, run `mkdir -p .pi/artifacts`. The chain writes its three durable artifacts there.
2. **Clean git state.** Run `git status --porcelain`. Stage 3 uses `subagent({worktree: true})` for parallel implementers, which requires a clean working tree. If there are uncommitted changes, surface them and ask the user whether to stash, commit, or proceed anyway (some early stages may still be useful even if stage 3 will fail).
3. **Confirm scope.** If the kickoff material below is unusually short or ambiguous, ask the user once to confirm what they want before launching — the chain runs at opus xhigh and burns real tokens; a malformed kickoff produces a malformed strategy.

## Launching the chain

Use the `subagent` tool. The chain is defined at `~/.pi/agent/chains/strategy-to-impl.chain.md`. Read that file, parse the four `## ` step headers and their bodies, then invoke:

```typescript
subagent({
  chain: [
    { agent: "chef-de-cuisine", task: <stage 1 body verbatim> },
    { agent: "chef-de-cuisine", task: <stage 2 body verbatim>, reads: [".pi/artifacts/strategy.md"] },
    { agent: "chef-de-cuisine", task: <stage 3 body verbatim>, reads: [".pi/artifacts/implementation-plan.md"] },
    { agent: "aboyeur",         task: <stage 4 body verbatim> },
  ],
  task: <kickoff material from $@ below>,
  clarify: false
})
```

If the user asked to run it in the background ("in the background", "async", "while I keep working"), pass `async: true` as well — completion will arrive via intercom notification. Otherwise run foreground so you can mediate the human-gate notifications interactively.

The `clarify: false` flag skips the chain-launch TUI; pass `clarify: true` only if the user explicitly asked to inspect or edit the chain before launch.

## Mediating the human-gate notifications

> **HARD RULE — read this before doing anything when a gate fires.**
>
> When `chef-de-cuisine` raises a human gate via `contact_supervisor`, its message will list a reply contract (`APPROVE | REVISE | MORE_WAVES | DENY`). **That list is for you (the orchestrator), not a menu to put to the user.** You translate Plannotator's result into one of those four replies. You do **not** open an `ask_user` asking the user to pick a verb before Plannotator has run. The browser annotation session is the user's review — prompting them to approve/revise/deny *before* they've reviewed is nonsense.
>
> Concretely, the very first thing you do when a gate fires is invoke `plannotator annotate <artifactPath>` via Bash. The `ask_user` verb picker only fires *after* Plannotator returns feedback (Case B in step 4 below).

In stages 1 and 2, `chef-de-cuisine` calls `contact_supervisor` after the AI review plateau, asking for human review of `.pi/artifacts/strategy.md` and `.pi/artifacts/implementation-plan.md` respectively.

When a gate notification arrives:

1. **Identify the gate.** From the pending intercom ask, extract `senderTarget` (e.g. `subagent-chef-de-cuisine-…`), `replyTo` (the ask's message id), `artifactPath` (from the `Artifact ready for review at: …` line), and a one-line `stageHint` (MENU/strategy.md vs PREP-LIST/implementation-plan.md).
2. **Surface a brief handoff** to the user — one short block with the artifact path, the stage, and chef-de-cuisine's wave summary (which sous-chef angles ran, what was accepted, what was deferred).
3. **Run Plannotator directly.** Invoke the `plannotator-annotate` skill yourself with Bash: `plannotator annotate <artifactPath>`. Do not ask the user to type `/plannotator-annotate` and do not ask for a verb first — the browser annotation UI *is* the review surface for this gate. Wait for the command to return.
4. **Process Plannotator's result and reply via intercom** with `intercom({action:"reply", to: senderTarget, replyTo: <ask id>, message: <formatted reply>})`:
   - **Approved with no feedback** → reply `APPROVE` immediately. The browser click was the confirmation; do not run a redundant `ask_user`.
   - **Returned feedback (denied / annotated).** Capture the feedback body verbatim, then run a single `ask_user` to pick the verb:
     - `REVISE — re-run this gate with the feedback` → reply `REVISE: <feedback verbatim>`.
     - `MORE_WAVES — spawn more sous-chef reviewers first` → ask one follow-up for `<N>` and optional `angles=…`, format as `MORE_WAVES: <N> [angles=…]`.
     - `DENY — kill the chain step` → ask one follow-up to confirm and capture the reason, format as `DENY: <reason>`.
   - **Plannotator session closed with no annotations and no approval signal** → ask the user once whether they want to APPROVE as-is or provide freeform feedback. If feedback, treat it like the feedback case above (verb picker → formatted reply).
   - **Plannotator failed to launch / file missing / Bash error** → surface the error in one line, then fall back to freeform: ask them to read the artifact in their editor and reply with feedback. Treat their response like the feedback case above.
5. **Loop on REVISE.** After a `REVISE` reply, chef-de-cuisine rewrites once and opens the gate again on the same artifact. When that next notification arrives, repeat from step 1 — i.e. re-run `plannotator annotate <artifactPath>` on the rewritten artifact so the user can re-annotate it. Keep looping until Plannotator returns approval (or the user picks `DENY`).

There is no cap on human-gate iterations — the user controls when each gate ends. AI plateau loops within each iteration are still capped at 5 sous-chef waves.

(The `/runner` slash prompt does the same bridging in a standalone turn if a gate notification arrives outside this orchestration. Inside `/chef`, do it inline as above — don't punt to `/runner`.)

## After the chain completes

Surface `.pi/artifacts/final-review-summary.md` to the user — that's aboyeur's output with the wave-by-wave findings, refire log, BLOCKING/NON-BLOCKING/AGREE counts, and plateau call. If the chain hit the wave cap (`STATUS: HIT_WAVE_CAP`) or any stage failed, explain what happened and what the user might do next (re-run with more waves, address open BLOCKINGs manually, etc.).

## Skipping the human gates

If the user wants to run unattended ("autopilot", "no review", "just run it through"), copy `~/.pi/agent/chains/strategy-to-impl.chain.md` to `~/.pi/agent/chains/strategy-to-impl-autopilot.chain.md` first, delete the two `[HUMAN GATE]` blocks (in stages 1 and 2), and invoke that chain instead. Mention this option in your pre-flight message if the user gives a kickoff that looks like throwaway/exploratory work.

---

Kickoff material from `/chef $@`:

$@
