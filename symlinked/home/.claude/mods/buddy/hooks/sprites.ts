// Sprites are composed the way ASCIIPunks draws its punks on-chain
// (github.com/asciilabs/asciipunks--contract, MIT): one stored seed, hashed
// once, and every slot picks its part as `rand % <slot count>`. A part that
// appears twice in a list is twice as likely, which is how rarity falls out.
//
// A body is 5 lines of at most 12 columns. Line 0 is the top slot (hats,
// hair, the punk "tops"); {L} {R} are the paired eyes, {M} the mouth.

export type Body = { base: string[]; fidget: string[]; mouths: string[] }

const twoEyedFace = (top: string, bottom: string): string[] => ['', top, '   │ {L} {R} │  ', '   │  {M}  │  ', bottom]

export const BODIES: Record<string, Body> = {
  duck: {
    base: ['', '    ┌──┐    ', '  {M}┤{L} │    ', '    │  └──┐ ', '    └─────┘ '],
    fidget: ['', '    ┌──┐    ', '  {M}┤{L} │    ', '    │  └──┐ ', '    └─────┘~'],
    mouths: ['◄═', '<─', '◄─', '═╡', '<═', '◄─'],
  },
  goose: {
    base: ['', '   ┌─┐      ', ' {M}┤{L}│      ', '    │└───┐  ', '    └────┘  '],
    fidget: ['', '   ┌─┐      ', ' {M}┤{L}│      ', '    │└───┐≈ ', '    └────┘  '],
    mouths: ['◄═', '<─', '◄─', '<═'],
  },
  blob: {
    base: ['', '   ┌────┐   ', '  ┌┘{L}  {R}└┐  ', '  │  {M}   │  ', '  └──────┘  '],
    fidget: ['', '  ┌──────┐  ', '  │ {L}  {R} │  ', '  │  {M}   │  ', '  └──────┘  '],
    mouths: ['─', 'o', '▾', '◡', '~', '─'],
  },
  cat: {
    base: ['', '   ╱╲   ╱╲  ', '  ┌┘└───┘└┐ ', '  │ {L} {M} {R} │ ', '  └┬─────┬┘ '],
    fidget: ['', '   ╱╲   ╱╲  ', '  ┌┘└───┘└┐ ', '  │ {L} {M} {R} │ ', '  └┬─────┬┘~'],
    mouths: ['ω', '▾', '^', 'w', '─', 'ω'],
  },
  dragon: {
    base: ['', '  ╱┌─────┐╲ ', '   │ {L} {R} │  ', '  ◄┤  {M}  ├► ', '   └┬┬─┬┬┘  '],
    fidget: ['', '  ╱┌─────┐╲ ', '   │ {L} {R} │  ', '  ═┤  {M}  ├═ ', '   └┬┬─┬┬┘  '],
    mouths: ['▼', '≈', 'w', '═', 'v', '▼'],
  },
  octopus: {
    base: ['', '   ┌─────┐  ', '   │ {L} {R} │  ', '   └┬┬┬┬┬┘  ', '   ╰╯╰╯╰╯╰  '],
    fidget: ['', '   ┌─────┐  ', '   │ {L} {R} │  ', '   └┬┬┬┬┬┘  ', '   ╯╰╯╰╯╰╯  '],
    mouths: [''],
  },
  owl: {
    base: ['', '   ╓──────╖ ', '   ║({L})({R})║ ', '   ║  {M}   ║ ', '   ╙─╨──╨─╜ '],
    fidget: ['', '  ╱╓──────╖╲', '   ║({L})({R})║ ', '   ║  {M}   ║ ', '   ╙─╨──╨─╜ '],
    mouths: ['▼', 'v', '◊', '▾', 'v'],
  },
  penguin: {
    base: ['', '    ┌───┐   ', '    │{L}{M}{R}│   ', '   ╱│   │╲  ', '    ╘═╧═╛   '],
    fidget: ['', '    ┌───┐   ', '    │{L}{M}{R}│   ', '   ─│   │╲  ', '    ╘═╧═╛   '],
    mouths: ['v', '▾', '▼', '◊', 'v'],
  },
  turtle: {
    base: ['', '  ┌─┬──┬─┐  ', '  ├─┴──┴─┼{L}┐', '  └┬────┬┴─┘', '   ╨    ╨   '],
    fidget: ['', '  ┌─┬──┬─┐  ', '  ├─┴──┴─┼{L}┐', '  └┬────┬┴─┘', '  ╨      ╨  '],
    mouths: [''],
  },
  snail: {
    base: ['', ' {L} {R}        ', ' │ │  ┌──┐  ', ' └─┘ ┌┘╭╮└┐ ', ' ╘═══╧════╛ '],
    fidget: ['', '  {L} {R}       ', ' │ │  ┌──┐  ', ' └─┘ ┌┘╭╮└┐ ', ' ╘═══╧════╛ '],
    mouths: [''],
  },
  ghost: {
    base: twoEyedFace('   ┌─────┐  ', '   ╰╮╭─╮╭╯  '),
    fidget: twoEyedFace('   ┌─────┐  ', '   ╭╯╰─╯╰╮  ').map(l => (l ? `${l.slice(1)} ` : l)),
    mouths: ['o', 'O', '○', '─', '◦', '~'],
  },
  axolotl: {
    base: ['', ' ╲╲┌────┐╱╱ ', ' ══│{L}  {R}│══ ', '   │ {M}  │   ', '   └┬──┬┘~  '],
    fidget: ['', ' ╱╱┌────┐╲╲ ', ' ══│{L}  {R}│══ ', '   │ {M}  │   ', '   └┬──┬┘~  '],
    mouths: ['ω', 'u', '◡', 'w', 'ω'],
  },
  capybara: {
    base: ['', '   ┌┐  ┌┐   ', '  ┌┴┴──┴┴┐  ', '  │{L}    {R}│  ', '  └──{M}──┘  '],
    fidget: ['', '   ┌┐  ╓╖   ', '  ┌┴┴──┴┴┐  ', '  │{L}    {R}│  ', '  └──{M}──┘  '],
    mouths: ['▀▀', '══', '┬┬', '══'],
  },
  cactus: {
    base: ['', '    ┌──┐    ', ' ┌┐ │{L}{R}│ ┌┐ ', ' └┴─┤{M} ├─┴┘ ', '   ╘╧══╧╛   '],
    fidget: ['', '    ┌*─┐    ', ' ┌┐ │{L}{R}│ ┌┐ ', ' └┴─┤{M} ├─┴┘ ', '   ╘╧══╧╛   '],
    mouths: ['─', 'o', '▾', '◡'],
  },
  robot: {
    base: ['', '   ┌──╨──┐  ', '   │ {L} {R} │  ', '  ╡│ {M}{M}{M} │╞ ', '   └┬───┬┘  '],
    fidget: ['', '   ┌──╫──┐  ', '   │ {L} {R} │  ', '  ╡│ {M}{M}{M} │╞ ', '   └┬───┬┘  '],
    mouths: ['═', '─', '≡', '┼', '■', '═'],
  },
  rabbit: {
    base: ['', '    ║   ║   ', '   ┌╨───╨┐  ', '   │ {L}{M}{R} │  ', '   └┬───┬┘  '],
    fidget: ['', '    ║   ╲   ', '   ┌╨───╨┐  ', '   │ {L}{M}{R} │  ', '   └┬───┬┘  '],
    mouths: ['x', 'ω', '▾', 'v', 'x'],
  },
  mushroom: {
    base: ['', '  ┌──────┐  ', ' ┌┘ ◦  ◦ └┐ ', ' └┬──────┬┘ ', '  │ {L}  {R} │  '],
    fidget: ['', '  ┌──────┐  ', ' ┌┘  ◦  ◦└┐ ', ' └┬──────┬┘ ', '  │ {L}  {R} │  '],
    mouths: [''],
  },
  chonk: {
    base: ['', '  ╱╲    ╱╲  ', ' ┌┘└────┘└┐ ', ' │ {L}    {R} │ ', ' └───{M}────┘ '],
    fidget: ['', '  ╱╲    ╱─  ', ' ┌┘└────┘└┐ ', ' │ {L}    {R} │ ', ' └───{M}────┘ '],
    mouths: ['ω', '▾', '─', 'w', 'ω'],
  },
}

// ASCIIPunks' paired eye lists, verbatim; a pair keeps a punk's two eyes in
// conversation (◄ ►, ╔ ╗, ♥ ♠).
export const LEFT_EYES = ['◕', '*', '♥', 'X', '⊙', '˘', 'α', '◉', '☻', '¬', '^', '═', '┼', '┬', '■', '─', 'û', '╜', 'δ', '│', '┐', '┌', '┌', '╤', '/', '\\', '/', '\\', '╦', '♥', '♠', '♦', '╝', '◄', '►', '◄', '►', 'I', '╚', '╔', '╙', '╜', '╓', '╥', '$', '○', 'N', 'x']
export const RIGHT_EYES = ['◕', '*', '♥', 'X', '⊙', '˘', 'α', '◉', '☻', '¬', '^', '═', '┼', '┬', '■', '─', 'û', '╜', 'δ', '│', '┐', '┐', '┌', '╤', '\\', '/', '/', '\\', '╦', '♠', '♣', '♦', '╝', '►', '◄', '◄', '◄', 'I', '╚', '╗', '╜', '╜', '╓', '╥', '$', '○', 'N', 'x']

// One-line tops after ASCIIPunks' three-line ones; index 0 (bare) is listed
// often so most buddies go hatless. Tops past a rarity's reach are rerolled
// down by `rand % reach`.
export const TOPS = [
  '', '', '', '', '', '',
  '   ┌┬┬┬┬┐   ', '   ╒╦╦╦╦╕   ', '    ││││    ', '    ║║║║    ', '   \\/////   ', '   ((((((   ',
  '    ╓┬╥┐    ', '   ▐▐▐▌▌▌   ', '    ⌂⌂⌂⌂    ', '     ///    ', '   ± ±± ±   ', '    ◙◙◙◙    ',
  '  ♫     ♪   ', '   ♣♥♦♠♣♥   ', '     [⌂]    ', '    ☼  ☼    ', '  /\\/\\/\\/\\  ', '    ↑↑↓↓    ',
]

export const EGG = [
  ['', '    ┌──┐    ', '   ┌┘  └┐   ', '   └┐  ┌┘   ', '    └──┘    '],
  ['', '    ┌──┐    ', '   ┌┘╲╱└┐   ', '   └┐  ┌┘   ', '    └──┘    '],
  ['', '    ┌╲╱┐    ', '   ┌┘╲╱└┐   ', '   └┐╱╲┌┘   ', '    └──┘    '],
]

export const HEARTS = ['   ♥    ♥   ', '  ♥  ♥  ♥   ', ' ♥   ♥   ♥  ', '   ♥  ♥     ']

// Body per 500ms tick: 0 base, 1 fidget, -1 blink.
export const IDLE = [0, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 1, 0, -1, 0]
