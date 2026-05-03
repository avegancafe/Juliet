---
argument-hint: <PRD, transcript, or kickoff transcript>
description: Run the brigade pi-subagents pipeline end-to-end on a PRD, transcript, or freeform request. Chef-de-cuisine drafts a narrative ELI5 strategy onepager (sous-chef AI review waves + your APPROVE/REVISE/MORE_WAVES/DENY approval) and then a numbered implementation plan (single sous-chef AI review, no human gate). Then chef-de-cuisine fans out chef-de-partie implementers in parallel git worktrees per dependency batch, and aboyeur runs the code-review-and-fix-refire loop with conditional health-inspector (security) and patissier (design QA). Add "in the background" / "async" to run stages 2–4 unattended after the strategy is approved; "autopilot" / "no review" to skip the strategy gate too. Artifacts land in `.pi/artifacts/`.
---

Run the brigade pi-subagents pipeline `strategy-to-impl` on the kickoff material below. Four sequential stages run by the kitchen-brigade agents:

1. **chef-de-cuisine** (MENU mode) — writes `.pi/artifacts/strategy.md` (one-page narrative ELI5 strategy onepager), drives the AI review loop with `sous-chef` reviewers, then opens a human review gate via `contact_supervisor`. **Launched as a standalone subagent call** (not a chain step) so the orchestrator turn stays alive to mediate the gate — see "Why standalone-then-chain" below.
2. **chef-de-cuisine** (PREP-LIST mode) — writes `.pi/artifacts/implementation-plan.md` (numbered tasks + dependencies + lane labels + acceptance criteria), drives a single-reviewer AI loop, then exits with an audit-trail summary. **No human gate**; the strategy was the human-judgment moment, the plan is mechanical fallout.
3. **chef-de-cuisine** (SERVICE mode) — fans out N parallel `chef-de-partie` implementers per dependency batch in worktrees, validates each batch.
4. **aboyeur** — code review + fix-refire loop on the resulting diff, with parallel `sous-chef` angle reviewers (correctness / tests / simplicity), conditional `health-inspector` (when the diff touches auth/data/external surfaces), conditional `patissier` (when a design spec was supplied). Routes BLOCKING fixes back to `chef-de-partie`. Writes `.pi/artifacts/final-review-summary.md`.

Stages 2–4 run together as a single chain after stage 1's approval, because none of them gate on the happy path.

## Pre-flight before launching

1. **Artifacts dir.** If `.pi/artifacts/` does not exist in the current cwd, run `mkdir -p .pi/artifacts`. The chain writes its three durable artifacts there.
2. **Clean git state.** Run `git status --porcelain`. Stage 3 uses `subagent({worktree: true})` for parallel implementers, which requires a clean working tree. If there are uncommitted changes, surface them and ask the user whether to stash, commit, or proceed anyway (some early stages may still be useful even if stage 3 will fail).
3. **Confirm scope.** If the kickoff material below is unusually short or ambiguous, ask the user once to confirm what they want before launching — the chain runs at opus xhigh and burns real tokens; a malformed kickoff produces a malformed strategy.

## Launching

### Why standalone-then-chain

pi-subagents chains cannot survive an intercom-detached child. When a chain step calls `contact_supervisor`, pi-subagents detaches the child for intercom coordination and the chain runner returns immediately with "Chain detached for intercom coordination at step N" — it does not wait for the child to receive its supervisor reply, and `subagent-executor.ts:245` explicitly says detached children "cannot be revived safely from the remembered foreground state." The next chain step never spawns. (See `chain-execution.ts:861` and `:625` for the two return points.)

Stage 1 has a human gate and therefore must be launched standalone, *outside* chain mode — the orchestrator turn (this prompt) stays alive to mediate the gate. Stages 2–4 are gateless on the happy path, so they can chain together and the chain runner survives end-to-end.

The stage bodies live at `~/.pi/agent/chains/strategy-to-impl.chain.md`. Read that file once and parse the four `## ` step headers; you'll use stage 1 in Phase A and stages 2–4 in Phase B.

### Phase A — stage 1 standalone

```typescript
subagent({
  agent: "chef-de-cuisine",
  task: <stage 1 body verbatim, with `{task}` substituted with the kickoff material below>,
  clarify: false
})
```

Note: `chain` mode would auto-substitute `{task}` for you; in standalone mode you substitute it yourself before the call. The kickoff material is the `$@` block at the bottom of this file.

When chef-de-cuisine raises the human gate, pi-subagents returns `Detached for intercom coordination: chef-de-cuisine. Reply to the supervisor request first.` — your turn is still alive. Mediate the gate (see "Mediating the strategy gate" below). On `REVISE`, chef-de-cuisine rewrites and re-opens the gate from inside the same detached child; loop until `APPROVE` or `DENY`.

After `APPROVE`, chef-de-cuisine's child exits with a turn-final audit-trail summary. Capture that summary text from the intercom history (or synthesize one from your gate-mediation log: number of AI waves, number of human-gate iterations, key revisions accepted, final disposition) — you'll feed it into Phase B as the chain's `task`.

### Phase B — stages 2–4 chain (after stage 1 APPROVE)

```typescript
subagent({
  chain: [
    { agent: "chef-de-cuisine", task: <stage 2 body verbatim>, reads: [".pi/artifacts/strategy.md"] },
    { agent: "chef-de-cuisine", task: <stage 3 body verbatim>, reads: [".pi/artifacts/implementation-plan.md"] },
    { agent: "aboyeur",         task: <stage 4 body verbatim> },
  ],
  task: <stage 1 audit-trail summary>,  // becomes {task} for the chain; {previous} threads naturally between steps
  async: <true if user said "in the background" / "async" / "while I keep working", else omit>,
  clarify: false
})
```

Foreground is fine for Phase B (stages 2–4 are non-interactive on the happy path). Async returns control to the user immediately; the final-review-summary intercom notification arrives when stage 4 finishes.

The `clarify: false` flag skips the chain-launch TUI; pass `clarify: true` only if the user explicitly asked to inspect or edit the chain before launch.

**Failure mode in Phase B.** Stage 3 escalates via `contact_supervisor` if a `chef-de-partie` implementer batch fails. That escalation also detaches and kills the chain (same bug as stage 1's gate). Stages 4 won't auto-spawn. If you see a stage 3 escalation, mediate it the same way you'd mediate the strategy gate, then — once the user has decided how to proceed — relaunch stage 4 as another standalone subagent call (`subagent({agent:"aboyeur", task:<stage 4 body>})`). Stage 4 (aboyeur) itself never gates, so once it starts it runs to completion.

## Mediating the strategy gate (Phase A only)

> **HARD RULE — read this before doing anything when the gate fires.**
>
> When the gate fires, you do **exactly one** thing in this turn: output a plain-text block telling the user to run `/plannotator-annotate <artifactPath>` in their TUI, then end your turn. **Do NOT open an `ask_user`.** Not for picking a verb, not for picking a review method, not for confirming Plannotator. The user types the slash command, annotates in the browser, and comes back with the result — *then* (and only then) do you process it and reply via intercom.
>
> The reply contract `APPROVE | REVISE | MORE_WAVES | DENY` listed in chef-de-cuisine's `contact_supervisor` message is the format **you** send back via `intercom reply`. It is not a menu to put to the user.

chef-de-cuisine calls `contact_supervisor` after the AI review plateau in Phase A (stage 1, MENU mode), asking for human review of `.pi/artifacts/strategy.md`. This is the only human gate in the pipeline. (Stage 2's `contact_supervisor` is reserved for batch-failure escalations from chef-de-partie in stage 3 — see Phase B failure mode above; stage 2 itself never gates.)

### Why a slash command and not a Bash call

The `plannotator-annotate` skill's SKILL.md says to invoke `plannotator annotate <path>` via Bash. **That is wrong for this environment.** Plannotator is installed here as a pi extension (`@plannotator/pi-extension`) that registers the slash command `/plannotator-annotate` — there is no `plannotator` binary on PATH. Agents cannot invoke slash commands from inside their own turn (slash commands are user-typed in the TUI). Therefore the only way to drive the review is to instruct the user to type the slash command. Do not waste a Bash attempt confirming this; just emit the instruction.

### Step 1 — Identify the gate (this turn)

From the pending intercom ask, extract:
- `senderTarget` (e.g. `subagent-chef-de-cuisine-…`),
- `replyTo` (the ask's message id),
- `artifactPath` (from the `Artifact ready for review at: …` line),
- `stageHint` (one line: MENU/strategy.md vs PREP-LIST/implementation-plan.md).

### Step 2 — Emit the slash-command instruction and end your turn

Output a single plain-text block. No `ask_user`, no Bash, no follow-up tool calls.

```
chef-de-cuisine has paused at the <stageHint> human gate.
Artifact: <artifactPath>

Wave summary:
- AI waves run: <N>
- Plateau reason: <reason>
- Top changes accepted from review: <bullets>
- Top NON-BLOCKING items deferred: <bullets>

To review, type this in your TUI:

    /plannotator-annotate <artifactPath>

The browser annotation UI will open. Approve in the browser to advance
the chain, or close with feedback to revise. Come back here with the
result and I'll translate it into the chain reply contract automatically.
```

Then stop. The chef-de-cuisine intercom ask stays pending; the chain is parked waiting for your `intercom reply`.

### Step 3 — Process Plannotator's result (next turn, after the user returns)

When the user's next message arrives, classify what they brought back and reply via `intercom({action:"reply", to: senderTarget, replyTo: <ask id>, message: <formatted reply>})`:

- **Approved with no feedback** → reply `APPROVE` immediately. No `ask_user`. The browser approval click was the confirmation.
- **Returned feedback (annotations / freeform notes).** Capture the feedback body verbatim, then run a single `ask_user` to pick the verb — this is the only `ask_user` in the whole gate flow, and it only fires when feedback came back from Plannotator:
  - `REVISE — re-run this gate with the feedback` → reply `REVISE: <feedback verbatim>`.
  - `MORE_WAVES — spawn more sous-chef reviewers first` → ask one follow-up for `<N>` and optional `angles=…`, format as `MORE_WAVES: <N> [angles=…]`.
  - `DENY — kill the chain step` → ask one follow-up to confirm and capture the reason, format as `DENY: <reason>`.
- **Plannotator session closed empty / user says nothing useful happened** → ask once: "Plannotator returned no feedback — APPROVE as-is, or do you have notes to relay?" If notes, treat like the feedback case; otherwise reply `APPROVE`.
- **User reports the slash command failed / Plannotator extension not installed** → surface the error in one line and fall back to freeform: ask them to read the artifact in their editor and paste feedback into chat. Treat their response like the feedback case (verb picker → formatted reply).

### Step 4 — Loop on REVISE

After a `REVISE` reply, chef-de-cuisine rewrites once and opens the gate again on the same artifact. When that next notification arrives, repeat from Step 1 — emit a fresh slash-command instruction for the rewritten artifact. Keep looping until Plannotator returns approval (or the user picks `DENY`). There is no cap on human-gate iterations — the user controls when each gate ends. AI plateau loops within each iteration are still capped at 5 sous-chef waves.

### Step 5 — APPROVE → launch Phase B

When Plannotator returns approval and you've sent `APPROVE` via intercom, chef-de-cuisine's child exits with a turn-final audit-trail summary. **Now launch Phase B** (stages 2–4 chain, see "Launching" above) with the audit-trail summary as the chain's `task` parameter so stage 2's `{previous}` placeholder has context to reference. If chef-de-cuisine's exact final response isn't easily recoverable from the intercom history, synthesize a one-paragraph summary yourself: number of AI waves, number of human-gate iterations, the key revisions accepted, and final disposition.

(The `/runner` slash prompt does the same Phase A bridging in a standalone turn if a gate notification arrives outside this orchestration — e.g. when `/chef` was launched async or the orchestrator session crashed. Inside `/chef`, do Phase A inline as above; don't punt to `/runner`.)

## After the chain completes

Surface `.pi/artifacts/final-review-summary.md` to the user — that's aboyeur's output with the wave-by-wave findings, refire log, BLOCKING/NON-BLOCKING/AGREE counts, and plateau call. If the chain hit the wave cap (`STATUS: HIT_WAVE_CAP`) or any stage failed, explain what happened and what the user might do next (re-run with more waves, address open BLOCKINGs manually, etc.).

## Skipping the human gate

If the user wants to run unattended ("autopilot", "no review", "just run it through"), bypass Phase A's mediation entirely: copy `~/.pi/agent/chains/strategy-to-impl.chain.md` to `~/.pi/agent/chains/strategy-to-impl-autopilot.chain.md`, delete the `[HUMAN GATE]` block from stage 1's body, and launch the full 4-stage chain in one shot:

```typescript
subagent({
  chain: [stage1, stage2, stage3, stage4],  // bodies parsed from the autopilot chain file
  task: <kickoff material>,
  async: <true if backgrounded>,
  clarify: false
})
```

With the gate removed, nothing in stages 1–2 detaches; the chain runner survives end-to-end. (Stage 3 batch-failure escalations are still possible but rare on well-scoped kickoffs.) Mention this autopilot option in your pre-flight message if the user gives a kickoff that looks like throwaway/exploratory work.

---

Kickoff material from `/chef $@`:

$@
