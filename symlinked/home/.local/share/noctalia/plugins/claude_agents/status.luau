--!nonstrict
-- Claude Code background agents in the bar.
--
-- A session that needs you rolls a die and lands on a face:
--   1-2  failed  - it hit a wall and doesn't know what to do   (red)
--   3-4  blocked - it's asking you a question                  (secondary)
--   5-6  done    - it succeeded, ready for your response       (primary)
-- (a `done` session only counts while its state.json is < DONE_FRESH_S old.)
-- Nothing needs you but something is working: typing robot. Otherwise: napping robot.
-- Next to it, a <=3-word summary of the headline session (+N if more need you).
--
-- Data: `claude agents --json` (roster) + ~/.claude/jobs/<id>/state.json (`detail`,
-- file mtime). The roster is published to shared state ("agents") for panel.luau.
-- Left click: wide panel.  Right click: `claude agents` in a terminal.

local TICK_MS = 250
local POLL_TICKS = 20 -- roster refresh every 5s
local ROLL_TICKS = 6 -- ~1.5s of tumbling before the die settles
local DONE_FRESH_S = 30 * 60

local DICE = { "⚀", "⚁", "⚂", "⚃", "⚄", "⚅" }
local ROBOT = {
  working = { "[o_o]>.  ", "[o_O]>.. ", "[O_o]>...", "[o_o]>   " },
  idle = { "[-_-] zZ ", "[-_-] Zz " },
}

local FILLER = { a = true, an = true, the = true, ["and"] = true, of = true, to = true, ["for"] = true, with = true, ["in"] = true, on = true, that = true, this = true, it = true, is = true, as = true }

-- "delivered agent roster, commands, and run workflow" -> "agent roster commands"
local function haiku(detail)
  if type(detail) ~= "string" or detail == "" then return "" end
  local words = {}
  for w in string.gmatch(string.lower(detail), "%a[%w_]*") do
    if not FILLER[w] then table.insert(words, w) end
  end
  -- Details are past-tense summaries ("delivered ...", "fixed ..."): drop the verb.
  if #words > 3 and string.sub(words[1], -2) == "ed" then table.remove(words, 1) end
  return table.concat(words, " ", 1, math.min(3, #words))
end

-- Stable 0/1 per session so a given session always lands on the same face.
local function parity(id)
  local sum = 0
  for i = 1, #id do sum += string.byte(id, i) end
  return sum % 2
end

-- state -> die face index (1-6), colour role, rank (lower = more urgent)
local function outcome(a)
  if a.state == "failed" then return 1 + parity(a.id), "error", 1 end
  if a.state == "blocked" then return 3 + parity(a.id), "secondary", 2 end
  if a.state == "done" and a.fresh then return 5 + parity(a.id), "primary", 3 end
  return nil
end

local agents = {}
local mode = "idle" -- "dice" | "working" | "idle"
local face, role = 1, "on_surface_variant"
local summary = ""
local lastKey = ""
local roll = 0
local tick = 0
local pollIn = 0
local polling = false

local function setMode(list)
  local best, bestRank, needs, working = nil, 99, 0, 0
  for _, a in ipairs(list) do
    local f, r, rank = outcome(a)
    if f then
      needs += 1
      if rank < bestRank then best, bestRank = a, rank end
    elseif a.state == "working" then
      working += 1
    end
  end
  if best then
    mode = "dice"
    face, role = outcome(best)
    summary = best.haiku
    if needs > 1 then summary = `{summary} +{needs - 1}` end
    local key = best.id .. best.state
    if key ~= lastKey then
      lastKey = key
      roll = ROLL_TICKS
    end
  elseif working > 0 then
    mode, role, lastKey = "working", "primary", ""
    summary = ""
    for _, a in ipairs(list) do
      if a.state == "working" then summary = a.haiku break end
    end
  else
    mode, role, lastKey, summary = "idle", "on_surface_variant", "", ""
  end
end

local function render()
  local text
  if mode == "dice" then
    local shown = face
    if roll > 0 then shown = math.random(1, 6) end
    text = `{DICE[shown]} {summary}`
  else
    local frames = ROBOT[mode]
    text = frames[(tick % #frames) + 1] .. summary
  end
  barWidget.setGlyphColor(role)
  barWidget.setColor(role)
  barWidget.setText(text)
  local rows = {}
  for _, a in ipairs(agents) do
    table.insert(rows, { key = a.state, value = a.name })
  end
  barWidget.setTooltip(#rows > 0 and rows or "No Claude agents")
end

local function finish(list)
  for _, a in ipairs(list) do
    local f, r = outcome(a)
    a.die = f and DICE[f] or ""
    a.role = r or (a.state == "working" and "primary" or "on_surface_variant")
  end
  agents = list
  setMode(list)
  noctalia.state.set("agents", list)
  polling = false
  render()
end

local function refresh()
  if polling then return end
  polling = true
  noctalia.runAsync({ "claude", "agents", "--json" }, function(result)
    local roster = result.exitCode == 0 and noctalia.json.decode(result.stdout) or nil
    if type(roster) ~= "table" then
      polling = false
      return
    end
    -- The roster also lists interactive sessions (no id/state); only background ones are jobs.
    local jobs = {}
    for _, a in ipairs(roster) do
      if a.kind == "background" and a.id then table.insert(jobs, a) end
    end
    roster = jobs
    local list, pending = {}, #roster
    if pending == 0 then return finish(list) end
    for i, a in ipairs(roster) do
      local entry = { id = tostring(a.id), name = tostring(a.name or a.id), state = tostring(a.state or ""), startedAt = a.startedAt, haiku = "", fresh = false }
      list[i] = entry
      local path = noctalia.expandPath(`~/.claude/jobs/{a.id}/state.json`)
      local info = noctalia.fileInfo(path)
      if info and type(info.mtime) == "number" then
        local mtime = if info.mtime > 1e12 then info.mtime / 1000 else info.mtime
        entry.fresh = (os.time() - mtime) < DONE_FRESH_S
      end
      noctalia.readFileAsync(path, function(contents)
        local job = contents and noctalia.json.decode(contents) or nil
        if type(job) == "table" then
          entry.haiku = haiku(job.detail)
          -- The job file's state (working/done/blocked/failed) is fresher than the roster's.
          if type(job.state) == "string" then entry.state = job.state end
        end
        pending -= 1
        if pending == 0 then finish(list) end
      end)
    end
  end)
end

noctalia.setUpdateInterval(TICK_MS)
refresh()

function update()
  tick += 1
  if roll > 0 then roll -= 1 end
  pollIn -= 1
  if pollIn <= 0 then
    pollIn = POLL_TICKS
    refresh()
  end
  render()
end

function onClick()
  noctalia.togglePanel("kyle/claude_agents:panel")
end

function onRightClick()
  noctalia.runInTerminal("claude agents")
end
