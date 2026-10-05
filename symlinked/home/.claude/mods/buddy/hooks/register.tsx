import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Pet, Stored } from '../types'

import { bones, bubbleLine, card, color, face, NAMES, newSeed, peakStat, pick, sprite, voice, wrap } from './companion'
import type { Fit } from './companion'

const pet = atom({ plugin: 'buddy', key: 'pet' } as const, null)
const tick = atom({ plugin: 'buddy', key: 'tick' } as const, 0)
const says = atom({ plugin: 'buddy', key: 'says' } as const, null)
const isHidden = atom({ plugin: 'buddy', key: 'isHidden' } as const, false)
const isMuted = atom({ plugin: 'buddy', key: 'isMuted' } as const, false)

// The punk lives in a narrow pane docked beside the transcript, so it narrows the
// conversation instead of pushing it up; the band above the prompt is its fallback.
const PANE = 'buddy'
const PANE_COLUMNS = 16
const TICK_MS = 500
const BUBBLE_MS = 10_000
const PET_MS = 2_500
const HATCH_MS = 3_000
// ponytail: fixed model-call cooldown; make it an option if it's too chatty or too quiet
const CHIRP_COOLDOWN_MS = 20_000


let bubbleUntil = 0
let petUntil = 0
let hatchUntil = 0
let lastChirpAt = -Infinity
// The bubble as last drawn on screen, which the model is told to fit (pane or one-row band).
let fit: Fit = { width: 12, lines: 6 }
const MAX_BUBBLE_LINES = 6
let lastPrompt = ''

async function say($: EngineInterface, text: string) {
  if (await read($, isMuted)) return
  bubbleUntil = (await $.clock.now()) + BUBBLE_MS
  await update($, says, () => text)
}

async function chirp($: EngineInterface, situation: string, isForced = false) {
  const mine = await read($, pet)
  const now = await $.clock.now()
  if (!mine || (await read($, isHidden)) || (await read($, isMuted))) return
  if (!isForced && now - lastChirpAt < CHIRP_COOLDOWN_MS) return
  lastChirpAt = now
  // Runs unawaited from hooks, so a failed call must not escape as an unhandled rejection.
  try {
    const ask = (prompt: string) =>
      $.model.complete({ model: 'haiku', maxTokens: 80, effort: 'low', system: voice(mine, fit), prompt })
    const fits = (line: string) => wrap(line, fit.width).length <= fit.lines
    const r = await ask(situation)
    let line = r.isAnswered ? bubbleLine(r.text) : null
    // Too long for the bubble: hand it back once with the measurements and ask again.
    if (line && !fits(line)) {
      const retry = await ask(
        `${situation}\n\nYou said: ${line}\nThat needs ${wrap(line, fit.width).length} lines, but your bubble holds ` +
          `${fit.lines} line${fit.lines === 1 ? '' : 's'} of ${fit.width} characters. Say it again, shorter.`,
      )
      const shorter = retry.isAnswered ? bubbleLine(retry.text) : null
      if (shorter && (fits(shorter) || shorter.length < line.length)) line = shorter
    }
    if (line) await say($, line)
  } catch {
    // no line this time; the bubble stays as it was
  }
}

async function hatch($: EngineInterface): Promise<Pet> {
  hatchUntil = (await $.clock.now()) + HATCH_MS
  await update($, isHidden, () => false)
  await $.store.set('isHidden', false)
  const body = bones(newSeed())
  let fresh: Pet = { ...body, name: pick(NAMES), personality: 'quietly judges your variable names' }
  await update($, pet, () => fresh)
  const stats = Object.entries(body.stats).sort((a, b) => a[1] - b[1])
  const r = await $.model.complete({
    model: 'haiku',
    maxTokens: 100,
    effort: 'low',
    system: 'You name tiny terminal pets. Reply with only a JSON object.',
    prompt:
      `A ${body.rarity} ASCII punk (a little box-drawn face, after the ASCIIPunks NFTs) just hatched in a developer's terminal. Strongest stat ${peakStat(body)}, ` +
      `weakest ${stats[0]![0]}. Reply {"name": "<short cute name>", "personality": "<one lowercase sentence under 12 words, specific and a little odd>"}`,
  })
  try {
    const soul = r.isAnswered ? JSON.parse(r.text.match(/\{[\s\S]*\}/)?.[0] ?? '') : null
    if (typeof soul?.name === 'string' && typeof soul?.personality === 'string') {
      fresh = { ...fresh, name: soul.name.slice(0, 16), personality: soul.personality.slice(0, 100) }
    }
  } catch {
    // keep the fallback name and personality
  }
  const stored: Stored = { seed: fresh.seed, name: fresh.name, personality: fresh.personality }
  await $.store.set('pet', stored)
  await update($, pet, () => fresh)
  await say($, `hi! i'm ${fresh.name}.`)
  void chirp($, 'You just hatched out of an egg in this terminal. Introduce yourself.', true)
  return fresh
}

async function openPane($: EngineInterface) {
  const mine = await read($, pet)
  if (mine && !(await read($, isHidden))) await $.ui.open({ id: PANE, title: mine.name, columns: PANE_COLUMNS })
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const saved = (await $.store.get('pet')) as Partial<Stored> | undefined
    if (saved?.name) {
      // A buddy from before seeds keeps its name and gets one.
      const seed = saved.seed ?? newSeed()
      const soul: Stored = { seed, name: saved.name, personality: saved.personality ?? 'quietly judges your variable names' }
      if (seed !== saved.seed) await $.store.set('pet', soul)
      // Bones win over anything stored, as the original's `{ ...stored, ...bones }` did.
      const mine: Pet = { ...soul, ...bones(seed) }
      await update($, pet, () => mine)
    }
    const [hidden, muted] = await Promise.all([$.store.get('isHidden'), $.store.get('isMuted')])
    await update($, isHidden, () => hidden === true)
    await update($, isMuted, () => muted === true)
    await $.command.register({ name: 'buddy', description: 'Your terminal buddy: pet, card, mute, unmute, off, on, hatch' })
    // Unasked, so the engine seats it only on a terminal 144+ columns wide; the band covers the rest.
    void openPane($)
    $.clock.every(TICK_MS, async () => {
      await update($, tick, n => n + 1)
      if (bubbleUntil && (await $.clock.now()) > bubbleUntil) {
        bubbleUntil = 0
        await update($, says, () => null)
      }
    })
    return next(e)
  })

  on('command.run', { command: 'buddy' }, async ($, e) => {
    const arg = e.args.trim().toLowerCase()
    const mine = await read($, pet)
    if (!mine || arg === 'hatch') {
      const fresh = await hatch($)
      await openPane($)
      return { text: `A ${fresh.rarity} punk hatched: ${fresh.name}!\n\n${card(fresh)}` }
    }
    if (arg === 'off' || arg === 'on') {
      await update($, isHidden, () => arg === 'off')
      await $.store.set('isHidden', arg === 'off')
      if (arg === 'off') await $.ui.close({ id: PANE })
      else await openPane($)
      return { text: arg === 'off' ? `${mine.name} is napping. /buddy on to wake them.` : `${mine.name} is back!` }
    }
    if (arg === 'mute' || arg === 'unmute') {
      await update($, isMuted, () => arg === 'mute')
      await $.store.set('isMuted', arg === 'mute')
      if (arg === 'mute') await update($, says, () => null)
      return { text: arg === 'mute' ? `${mine.name} will keep their thoughts to themselves.` : `${mine.name} has opinions again.` }
    }
    if (arg === 'pet') {
      petUntil = (await $.clock.now()) + PET_MS
      await update($, isHidden, () => false)
      await say($, '♥')
      void chirp($, 'The developer just petted you.', true)
      return { text: `You pet ${mine.name}.` }
    }
    return { text: card(mine) }
  })

  on('prompt.compose', async ($, e, next) => {
    const result = await next(e)
    const mine = await read($, pet)
    if (!mine || (await read($, isHidden))) return result
    const text =
      `A small ASCII punk named ${mine.name} sits beside the user's input box and occasionally comments in a speech bubble. ` +
      `You are not ${mine.name}; it is a separate watcher with its own voice. When the user addresses ${mine.name} directly, ` +
      `its bubble answers. Keep your own reply to one short line then, or answer only the part meant for you. ` +
      `Don't explain that you aren't ${mine.name}, and never speak for it.`
    return { ...result, sections: [...result.sections, { id: 'buddy:companion', text, scope: 'session' as const }] }
  })

  on('prompt.submit', async ($, e, next) => {
    lastPrompt = e.text
    const mine = await read($, pet)
    if (mine && new RegExp(`\\b${mine.name.replace(/\W/g, '')}\\b`, 'i').test(e.text)) {
      void chirp($, `The developer just said to you: "${e.text.slice(0, 500)}". Answer them.`, true)
    }
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    const ran = await next(e)
    if (!e.agentId && 'isError' in ran && ran.isError) {
      const text = 'text' in ran && typeof ran.text === 'string' ? ran.text.slice(0, 300) : ''
      void chirp($, `Claude's ${e.tool} call just failed${text ? `: ${text}` : ''}. React.`)
    }
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    if (!e.agentId && !e.isAborted) {
      void chirp(
        $,
        `The developer asked Claude: "${lastPrompt.slice(0, 400)}"\n` +
          `After ${Math.round(e.durationMs / 1000)}s Claude answered: "${e.answer.slice(0, 600)}"\nReact.`,
      )
    }
    return next(e)
  })

  // The card is art: drawn line by line, so the row keeps its leading spaces and blank lines.
  on('ui.render', { component: 'CommandOutput', props: { command: 'buddy' } }, ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    return (
      <Box flexDirection="column">
        {e.props.text.split('\n').map((line, i) => (
          <Text key={`c${i}`}>{line || ' '}</Text>
        ))}
      </Box>
    )
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const mine = await read($, pet)
    if (e.props.hasSurvey || !mine || (await read($, isHidden))) return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const n = await read($, tick)
    const now = await $.clock.now()
    const bubble = (await read($, isMuted)) ? null : await read($, says)
    const tint = color(mine, n)

    // The pane has the punk while it's on screen; otherwise the band carries a one-line face.
    const shown = (await $.ui.panes()).some(p => p.id === PANE && p.isPlaced && p.isShown)
    if (shown) return next(e)
    fit = { width: Math.max(12, e.props.bodyColumns - [...face(mine)].length - mine.name.length - 6), lines: 1 }
    return (
      <Box flexDirection="row" justifyContent="flex-end">
        {bubble ? <Text wrap="truncate-end">“{bubble}” </Text> : null}
        <Text color={tint}>{face(mine)} </Text>
        <Text dimColor>{mine.name}</Text>
      </Box>
    )
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e, next) => {
    const mine = await read($, pet)
    if (!mine) return next(e)

    const els = $.ui.resolve(e)
    const { Box, Text } = els
    const n = await read($, tick)
    const now = await $.clock.now()
    const bubble = (await read($, isMuted)) ? null : await read($, says)
    const tint = color(mine, n)
    const lines = sprite(mine, { tick: n, isPetting: now < petUntil, isHatching: now < hatchUntil })
    // The bubble gets the pane's width less its border and padding, and whatever rows
    // the punk and its name leave, so the whole quip shows.
    const width = Math.max(8, e.props.bodyColumns - 4)
    const room = Math.max(1, e.props.scroll.bodyRows - lines.length - 1 - 2)
    fit = { width, lines: Math.min(room, MAX_BUBBLE_LINES) }

    // Bottom-aligned, so the punk sits next to the prompt like the original sat beside the input.
    return (
      <Box flexDirection="column" justifyContent="flex-end" alignItems="center" height={e.props.scroll.bodyRows}>
        {bubble ? (
          <Box key="bubble" flexDirection="column" borderStyle="round" borderDimColor paddingX={1}>
            {wrap(bubble, width, room).map((l, i) => (
              <Text key={`b${i}`}>{l}</Text>
            ))}
          </Box>
        ) : null}
        {e.surface !== 'terminal' && 'Svg' in els ? (
          // Text draws in the app's proportional font off-terminal, which shears the punk's columns.
          <els.Svg key="sprite" source={spriteSvg(lines, tint)} alt={`${mine.name}, a pixel punk`} />
        ) : (
          lines.map((l, i) => (
            <Text key={`s${i}`} color={tint}>
              {l}
            </Text>
          ))
        )}
        <Text key="name" dimColor>
          {mine.name}
        </Text>
      </Box>
    )
  })
}

// The sprite as monospace SVG text, for surfaces whose Text is not drawn in a terminal cell grid.
function spriteSvg(lines: string[], tint: string): string {
  const size = 14
  const lineHeight = Math.round(size * 1.2)
  const cols = Math.max(1, ...lines.map(l => [...l].length))
  const width = Math.ceil(cols * size * 0.6) + 2
  const height = lines.length * lineHeight + 4
  const esc = (t: string) => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  const rows = lines
    .map((l, i) => `<text x="1" y="${(i + 1) * lineHeight}" xml:space="preserve">${esc(l)}</text>`)
    .join('')
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" font-family="ui-monospace, SFMono-Regular, Menlo, monospace" font-size="${size}" fill="${tint}" style="white-space:pre">${rows}</svg>`
}
