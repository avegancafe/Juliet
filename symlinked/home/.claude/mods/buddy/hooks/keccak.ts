// keccak256, as the ASCIIPunks contract hashes its seed (Ethereum's Keccak,
// 0x01 padding, not NIST SHA3-256). Lanes are 64-bit BigInts: slow, but it
// runs once per load, never per frame.

const MASK = (1n << 64n) - 1n
const RC = [
  0x0000000000000001n, 0x0000000000008082n, 0x800000000000808an, 0x8000000080008000n,
  0x000000000000808bn, 0x0000000080000001n, 0x8000000080008081n, 0x8000000000008009n,
  0x000000000000008an, 0x0000000000000088n, 0x0000000080008009n, 0x000000008000000an,
  0x000000008000808bn, 0x800000000000008bn, 0x8000000000008089n, 0x8000000000008003n,
  0x8000000000008002n, 0x8000000000000080n, 0x000000000000800an, 0x800000008000000an,
  0x8000000080008081n, 0x8000000000008080n, 0x0000000080000001n, 0x8000000080008008n,
]
// Rotation offsets, indexed x + 5y.
const ROT = [0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14]
const RATE = 136

const rotl = (v: bigint, n: number) => (n === 0 ? v : ((v << BigInt(n)) | (v >> BigInt(64 - n))) & MASK)

function permute(s: bigint[]) {
  for (const rc of RC) {
    const c = [0, 1, 2, 3, 4].map(x => s[x]! ^ s[x + 5]! ^ s[x + 10]! ^ s[x + 15]! ^ s[x + 20]!)
    for (let x = 0; x < 5; x++) {
      const d = c[(x + 4) % 5]! ^ rotl(c[(x + 1) % 5]!, 1)
      for (let y = 0; y < 25; y += 5) s[x + y] = s[x + y]! ^ d
    }
    const b: bigint[] = new Array(25)
    for (let x = 0; x < 5; x++) {
      for (let y = 0; y < 5; y++) b[y + 5 * ((2 * x + 3 * y) % 5)] = rotl(s[x + 5 * y]!, ROT[x + 5 * y]!)
    }
    for (let i = 0; i < 25; i++) {
      const x = i % 5
      const row = i - x
      s[i] = b[i]! ^ (~b[row + ((x + 1) % 5)]! & MASK & b[row + ((x + 2) % 5)]!)
    }
    s[0] = s[0]! ^ rc
  }
}

export function keccak256(data: Uint8Array): Uint8Array {
  const padded = new Uint8Array(Math.ceil((data.length + 1) / RATE) * RATE)
  padded.set(data)
  padded[data.length] = 0x01
  padded[padded.length - 1] = 0x80 | padded[padded.length - 1]!
  const s: bigint[] = new Array(25).fill(0n)
  for (let block = 0; block < padded.length; block += RATE) {
    for (let lane = 0; lane < RATE / 8; lane++) {
      let v = 0n
      for (let k = 7; k >= 0; k--) v = (v << 8n) | BigInt(padded[block + lane * 8 + k]!)
      s[lane] = s[lane]! ^ v
    }
    permute(s)
  }
  const out = new Uint8Array(32)
  for (let i = 0; i < 32; i++) out[i] = Number((s[i >> 3]! >> BigInt((i & 7) * 8)) & 0xffn)
  return out
}

export const hex = (bytes: Uint8Array) => Array.from(bytes, b => b.toString(16).padStart(2, '0')).join('')
export const unhex = (text: string) => Uint8Array.from(text.match(/../g) ?? [], b => parseInt(b, 16))
