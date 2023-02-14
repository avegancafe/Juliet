import { intro, outro, text, isCancel, cancel, spinner } from '@clack/prompts'
import { exec as internalExec } from 'child_process'
import util from 'util'

const exec = util.promisify(internalExec)

const info = (x) => {
  const s = spinner()
  s.start()
  s.stop(x)
}

intro(`git hoard`)

const { stdout } = await exec('git branch -a')

const xs = stdout.match(/hoard\/(\d+)/gi) || []

const maxHoard = xs
  .map((x) => parseInt(x.match(/\d+/)[0]))
  .reduce((agg, x) => (x > agg ? x : agg), -Infinity)

const newHoard = (maxHoard == -Infinity ? 0 : maxHoard) + 1

const branchName = await text({
  message: 'What would you like to name your hoard?',
  initialValue: `hoard/${newHoard}`,
})

if (isCancel(branchName)) {
  cancel('Exiting...')
  process.exit(0)
}

let s = spinner()

s.start(`Creating branch ${branchName}...`)
await exec(`git switch -c ${branchName}`)

s.stop(`Work saved in branch ${branchName}`)

const saveMessage = await text({
  message: 'What should the saved message be?',
  placeholder: 'No specified description-- saved with hoard',
})

if (isCancel(saveMessage)) {
  cancel('Exiting...')
  process.exit(0)
}

s = spinner()

s.start('Committing...')
await exec(`git commit -m'[hoard] ${saveMessage}' --allow-empty`)
s.stop('Committed!')

await exec(`git switch -`)

outro(`You're all set!`)
