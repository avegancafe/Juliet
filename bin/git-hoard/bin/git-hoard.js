import {
  intro,
  outro,
  text,
  isCancel,
  cancel,
  spinner,
  select,
} from '@clack/prompts'
import { exec as internalExec } from 'child_process'
import util from 'util'

const exec = util.promisify(internalExec)

const info = (x) => {
  const s = spinner()
  s.start()
  s.stop(x)
}

async function createHoard() {
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
}

async function listHoard() {
  intro(`git hoard list`)
  const { stdout: hoards } = await exec(
    'git branch -a | grep hoard/ | sed -E "s/hoard\\/(.*)/\\1/g"'
  )

  let normalizedHoards = hoards
    .split('\n')
    .map((x) => x?.trim())
    .filter((x) => x?.length)

  const commitMessages = (
    await Promise.all(
      normalizedHoards.map(async (x) => {
        const { stdout } = await exec(
          `git log --pretty -1 hoard/${x}  | grep "\\[hoard\\]" | sed -E 's/.*\\[hoard\\](.*)/\\1/g'`
        )

        return stdout?.trim()
      })
    )
  ).reduce((agg, x, i) => {
    return {
      ...agg,
      [normalizedHoards[i]]: x,
    }
  }, {})

  normalizedHoards = normalizedHoards.filter((x) => commitMessages[x] != '')

  let newHoard
  if (normalizedHoards.length) {
    newHoard = await select({
      message: 'Select which hoard to switch to',
      options: normalizedHoards.map((x) => ({
        value: x.trim(),
        hint: commitMessages[x],
      })),
    })
    if (isCancel(newHoard)) {
      cancel('Exiting...')
      process.exit(0)
    }
  } else {
    cancel('No hoards found')
    process.exit(0)
  }

  if (isCancel(newHoard)) {
    cancel('Exiting...')
    process.exit(0)
  }

  let s = spinner()

  s.start(`Checking out ${newHoard}...`)

  try {
    await exec(`git switch hoard/${newHoard}`)
  } catch (e) {
    console.error(e.stderr)
    s.stop(`Error checking out ${newHoard}`)
    cancel('Exiting...')
    process.exit(1)
  }
  s.stop(`Checked out ${newHoard}`)

  outro(`You're all set!`)
}

const args = process.argv.slice(2)

if (args.length == 0) {
  createHoard()
} else if (args.length == 1) {
  listHoard()
} else {
  console.log('Exiting...')
  process.exit(1)
}
