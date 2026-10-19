--!nonstrict
-- Claude Code sessions (background jobs and interactive) in the bar.
--
-- A session that needs you rolls a die and lands on a face:
--   1-2  failed  - it hit a wall and doesn't know what to do   (red)
--   3-4  blocked - it's asking you a question                  (secondary)
--   5-6  done    - it succeeded, ready for your response       (primary)
-- (a `done` session only counts while fresh: DONE_FRESH_S background, INT_FRESH_S interactive.)
-- Nothing needs you but something is working: the die shuffles faces nonstop.
-- Nothing running at all: sleeping robot with neon-sign z's (see NEON).
-- A failed/blocked die bounces like a Dock icon asking for attention (failed faster). Next to it: Claude Code 5h / 7d usage
-- meters (dimmed when stale). Names, reasons and context fill live in the tooltip / panel.
--
-- Data: `claude agents --json` is the roster (who is alive, names). Each session's
-- agents-feed mod (symlinked/home/.claude/mods/agents-feed) writes
-- ~/.cache/claude-agents/<sessionId>.json (state, reason, context) and _usage.json
-- (rate limits), and pings `onIpc("refresh")` on every change. Background jobs also
-- have ~/.claude/jobs/<id>/state.json, whose state matches the agents view.
-- The joined list is published to shared state ("agents") for panel.luau.
-- Left click: wide panel.  Right click: `claude agents` in a terminal.

local TICK_MS = 73 -- a tumbling die shows a new face every tick (~14/s)
local SLOW = 2 -- the neon z's step every SLOW ticks (~146ms)
local POLL_TICKS = 68 -- roster + usage refresh every ~5s (the feed's ping makes it sooner)
local ROLL_TICKS = 20 -- ~1.5s of tumbling before the die settles
local DONE_FRESH_S = 30 * 60
local INT_FRESH_S = 5 * 60 -- every interactive turn ends "done": let it go quickly
local USAGE_STALE_S = 15 * 60
local FEED_DIR = "~/.cache/claude-agents"
local USAGE_PATHS = { FEED_DIR .. "/_usage.json" }

-- Dock-style bounce: the "floor" is the die's normal resting spot, centred in the
-- bar like every other icon; it hops up from there under constant gravity (height
-- is a parabola in time: fast off the floor, slow at the top, fast back down),
-- makes a small damped rebound, and settles back exactly where it sits. Height
-- comes from wall-clock time, so it stays a true parabola however the 73ms ticks
-- sample it. The cell is centred in the 34px bar, so its top half is the headroom.
local CELL_H = 32
local DIE_PX = 18
local REST_PX = (CELL_H - DIE_PX) / 2 -- die centred in the cell
local HOP_PX = CELL_H - DIE_PX - REST_PX -- headroom above the resting spot
-- Per state: one cycle's length, and its hops as {share of the cycle, share of HOP_PX};
-- what's left of the cycle is rest on the floor.
local BOUNCE = {
  blocked = { period = 1200, hops = { { 0.42, 1 }, { 0.16, 0.22 } } },
  failed = { period = 700, hops = { { 0.6, 1 }, { 0.2, 0.18 } } },
}

-- Pixels above the resting spot at time nowMs for the given BOUNCE entry.
local function lift(spec, nowMs)
  local t = (nowMs % spec.period) / spec.period
  for _, hop in ipairs(spec.hops) do
    local share, height = hop[1], hop[2]
    if t < share then
      local x = t / share
      return HOP_PX * height * 4 * x * (1 - x)
    end
    t -= share
  end
  return 0
end

-- Sleeping robot: the z's light up like a neon sign - switch on one tube at a time,
-- hold, buzz with a flicker, then start over at one z (it only ever counts up: 1, 2, 3, 1, 2, 3...).
-- {text, lit, steps} (a step is SLOW ticks, 150ms); text is always 3 wide so the bar never reflows.
-- Unlit = dimmed tube.
local NEON = {
  { "z  ", true, 3 },
  { "zz ", true, 3 },
  { "zzz", true, 4 },
  -- flicker: all three z's blink, never dropping back to two
  { "zzz", false, 1 }, { "zzz", true, 1 }, { "zzz", false, 1 }, { "zzz", true, 1 },
  { "zzz", false, 1 }, { "zzz", true, 6 },
}
local NEON_TIMELINE = {}
for _, step in ipairs(NEON) do
  for _ = 1, step[3] do table.insert(NEON_TIMELINE, step) end
end

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
local settled = "" -- state of the die's session: failed | blocked | done
local usage = nil
local lastKey = ""
local roll = 0
local tick = 0
local pollIn = 0
local polling = false

local function setMode(list)
  local best, bestRank, needs, working = nil, 99, 0, 0
  for _, a in ipairs(list) do
    if a.state == "working" then working += 1 end
  end
  for _, a in ipairs(list) do
    local f, r, rank = outcome(a)
    -- A finished session only claims the die once nothing is still running; while
    -- work is in flight the die keeps tumbling. Failed/blocked always win.
    if f and not (rank == 3 and working > 0) then
      needs += 1
      if rank < bestRank then best, bestRank = a, rank end
    end
  end
  if best then
    mode = "dice"
    settled = best.state
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

-- "▰▰▱▱▱" for a 0-100 percentage
local function meter(pct)
  local filled = math.floor(pct / 20 + 0.5)
  return string.rep("▰", filled) .. string.rep("▱", 5 - filled)
end

local function usageColor(pct, stale)
  if stale then return "on_surface_variant" end
  if pct >= 90 then return "error" end
  if pct >= 70 then return "secondary" end
  return "on_surface"
end

local function seconds(t)
  if type(t) ~= "number" then return 0 end
  return if t > 1e12 then t / 1000 else t
end

-- The feed's _usage.json {at(ms), rateLimits = [{kind, percentUsed}]} as
-- { at = seconds, five = pct?, seven = pct? }.
local function readUsage(snap)
  if type(snap) ~= "table" or type(snap.rateLimits) ~= "table" then return nil end
  local out = { at = seconds(snap.at) }
  for _, r in ipairs(snap.rateLimits) do
    if r.kind == "five_hour" then out.five = r.percentUsed end
    if r.kind == "seven_day" then out.seven = r.percentUsed end
  end
  if out.five == nil and out.seven == nil then return nil end
  return out
end

-- {label, pct, stale} per available window.
local function usageParts()
  local parts = {}
  if not usage then return parts end
  local stale = (os.time() - usage.at) > USAGE_STALE_S
  if type(usage.five) == "number" then table.insert(parts, { "5h", usage.five, stale }) end
  if type(usage.seven) == "number" then table.insert(parts, { "7d", usage.seven, stale }) end
  return parts
end

local function render()
  local lead
  if mode == "dice" or mode == "working" then
    -- Working: the die never settles, it shuffles every tick. Dice: it tumbles
    -- once when the headline changes, then holds its face.
    local shown = face
    if mode == "working" or roll > 0 then shown = math.random(1, 6) end
    -- Every die rests at the same centred spot; a bouncing one hops up from it.
    local up = REST_PX
    local spec = mode == "dice" and roll == 0 and BOUNCE[settled]
    if spec then up += lift(spec, noctalia.nowMs()) end
    -- An invisible fixed-height box under the die is its height above the cell's
    -- bottom (ui.spacer flexes, so it can't hold a height).
    lead = ui.column({ height = CELL_H, width = DIE_PX, justify = "end", align = "center" }, {
      ui.glyph({ name = `dice-{shown}-filled`, size = DIE_PX, color = role }),
      ui.box({ width = 1, height = math.floor(up + 0.5), opacity = 0 }),
    })
  else
    local step = NEON_TIMELINE[(math.floor(tick / SLOW) % #NEON_TIMELINE) + 1]
    lead = ui.row({ gap = 6, align = "center" }, {
      ui.label({ text = "[-_-]", color = "on_surface_variant" }),
      ui.label({ text = step[1], color = step[2] and "secondary" or "on_surface_variant", opacity = step[2] and 1 or 0.45 }),
    })
  end

  local nodes = { lead }
  for _, p in ipairs(usageParts()) do
    table.insert(nodes, ui.label({ text = p[1], color = "on_surface_variant" }))
    table.insert(nodes, ui.label({ text = `{meter(p[2])} {math.floor(p[2] + 0.5)}%`, color = usageColor(p[2], p[3]) }))
  end
  barWidget.render(ui.row({ gap = 6, align = "center" }, nodes))

  local rows = {}
  for _, a in ipairs(agents) do
    table.insert(rows, { key = a.state, value = if a.kind == "interactive" then `{a.name} (int)` else a.name })
  end
  for _, p in ipairs(usageParts()) do
    table.insert(rows, { key = p[1] .. " usage", value = `{math.floor(p[2] + 0.5)}%{p[3] and " (stale)" or ""}` })
  end
  barWidget.setTooltip(#rows > 0 and rows or "No Claude agents")
end

local function finish(list)
  for _, a in ipairs(list) do
    local f, r = outcome(a)
    a.face = f -- Tabler `dice-<face>-filled` in the panel; nil when it doesn't need you
    a.role = r or (a.state == "working" and "primary" or "on_surface_variant")
  end
  agents = list
  setMode(list)
  noctalia.state.set("agents", list)
  polling = false
  render()
end

-- First usable snapshot in USAGE_PATHS order.
local function refreshUsage(i)
  i = i or 1
  local path = USAGE_PATHS[i]
  if not path then return end
  noctalia.readFileAsync(noctalia.expandPath(path), function(contents)
    local snap = readUsage(contents and noctalia.json.decode(contents) or nil)
    if snap then usage = snap else refreshUsage(i + 1) end
  end)
end

local function readJson(path, cb)
  noctalia.readFileAsync(noctalia.expandPath(path), function(contents)
    local value = contents and noctalia.json.decode(contents) or nil
    cb(if type(value) == "table" then value else nil)
  end)
end

-- Feed states -> the widget's: idle/ended sessions are just idle.
local FEED_STATE = { working = "working", blocked = "blocked", failed = "failed", done = "done", idle = "idle", ended = "idle" }

-- Fill entry from its feed file and, for a background job, its job file.
-- The job file's state is the agents view's own, so it wins for background jobs;
-- the feed adds the real reason text and the context fill.
local function join(entry, feed, job)
  local updated = 0
  if feed then
    entry.state = FEED_STATE[feed.state] or entry.state
    entry.reason = type(feed.reason) == "string" and feed.reason or ""
    entry.haiku = type(feed.summary) == "string" and feed.summary or ""
    if type(feed.context) == "table" and type(feed.context.percent) == "number" then entry.ctx = feed.context.percent end
    updated = seconds(feed.updatedAt)
  end
  if job then
    if type(job.state) == "string" then entry.state = job.state end
    if entry.reason == "" and type(job.detail) == "string" then
      entry.reason = job.detail
      entry.haiku = haiku(job.detail)
    end
    local info = noctalia.fileInfo(noctalia.expandPath(`~/.claude/jobs/{entry.id}/state.json`))
    if info and type(info.mtime) == "number" then updated = math.max(updated, seconds(info.mtime)) end
  end
  local window = if entry.kind == "background" then DONE_FRESH_S else INT_FRESH_S
  entry.fresh = updated > 0 and (os.time() - updated) < window
end

local function refresh()
  refreshUsage()
  if polling then return end
  polling = true
  noctalia.runAsync({ "claude", "agents", "--json" }, function(result)
    local roster = result.exitCode == 0 and noctalia.json.decode(result.stdout) or nil
    if type(roster) ~= "table" then
      polling = false
      return
    end
    local list = {}
    for _, a in ipairs(roster) do
      if type(a.sessionId) == "string" then
        local kind = if a.kind == "background" then "background" else "interactive"
        -- Interactive sessions have no job id or state in the roster: busy/idle only.
        local state = if kind == "background" then tostring(a.state or "") elseif a.status == "busy" then "working" else "idle"
        table.insert(list, {
          id = tostring(a.id or string.sub(a.sessionId, 1, 8)),
          sessionId = a.sessionId,
          kind = kind,
          name = tostring(a.name or a.id or string.sub(a.sessionId, 1, 8)),
          state = state,
          startedAt = a.startedAt,
          reason = "",
          haiku = "",
          fresh = false,
        })
      end
    end
    local pending = #list
    if pending == 0 then return finish(list) end
    for _, entry in ipairs(list) do
      readJson(`{FEED_DIR}/{entry.sessionId}.json`, function(feed)
        local function done(job)
          join(entry, feed, job)
          pending -= 1
          if pending == 0 then finish(list) end
        end
        if entry.kind == "background" then readJson(`~/.claude/jobs/{entry.id}/state.json`, done) else done(nil) end
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

-- The agents-feed mod pings this on every change: refresh on the next tick.
function onIpc(event)
  if event == "refresh" then pollIn = 0 end
end

function onClick()
  noctalia.togglePanel("kyle/claude_agents:panel")
end

function onRightClick()
  noctalia.runInTerminal("claude agents")
end
