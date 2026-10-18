--!nonstrict
-- Claude Code background agents: animated ASCII robot + a <=3-word summary of the
-- session that most needs you. Data comes from `claude agents --json` (roster) and
-- ~/.claude/jobs/<id>/state.json (each session's one-line `detail`).
--
--   typing robot  something is working
--   blinking red  a session needs you (any state other than working/done)
--   sleeping      everything is done / nothing running
--   Left click: wide agents panel.  Right click: `claude agents` in a terminal.
-- The roster is published to the plugin's shared state ("agents") for panel.luau.

local TICK_MS = 250
local POLL_TICKS = 20 -- roster refresh every 5s

local FRAMES = {
  working = { "[o_o]>.  ", "[o_O]>.. ", "[O_o]>...", "[o_o]>   " },
  attention = { "[!_!] ! ", "[o_o] ? " },
  done = { "[-_-] zZ ", "[-_-] Zz " },
  none = { "[-_-]    " },
}

local FILLER = { a = true, an = true, the = true, ["and"] = true, of = true, to = true, ["for"] = true, with = true, ["in"] = true, on = true }

-- "delivered agent roster, commands, and run workflow" -> "agent roster commands"
local function haiku(detail)
  if type(detail) ~= "string" or detail == "" then return "" end
  local words = {}
  for w in string.gmatch(string.lower(detail), "[%w%-_]+") do
    if not FILLER[w] then table.insert(words, w) end
  end
  -- Details are past-tense summaries ("delivered ...", "fixed ..."): drop the verb.
  if #words > 3 and string.sub(words[1], -2) == "ed" then table.remove(words, 1) end
  return table.concat(words, " ", 1, math.min(3, #words))
end

local agents = {}
local mode = "none"
local summary = ""
local tick = 0
local pollIn = 0
local polling = false

local function setMode(agentList)
  local working, attention = 0, 0
  local firstAttention, firstWorking = nil, nil
  for _, a in ipairs(agentList) do
    if a.state == "working" then
      working += 1
      firstWorking = firstWorking or a
    elseif a.state ~= "done" then
      attention += 1
      firstAttention = firstAttention or a
    end
  end
  if attention > 0 then
    mode = "attention"
  elseif working > 0 then
    mode = "working"
  elseif #agentList > 0 then
    mode = "done"
  else
    mode = "none"
  end
  local headline = firstAttention or firstWorking
  summary = headline and headline.haiku or ""
  if attention > 1 then summary = `{summary} +{attention - 1}` end
end

local function colorFor()
  if mode == "attention" then return "error" end
  if mode == "working" then return "primary" end
  return "on_surface_variant"
end

local function render()
  local frames = FRAMES[mode]
  local frame = frames[(tick % #frames) + 1]
  barWidget.setGlyphColor(colorFor())
  barWidget.setColor(colorFor())
  barWidget.setText(frame .. summary)
  local rows = {}
  for _, a in ipairs(agents) do
    table.insert(rows, { key = a.state, value = a.name })
  end
  barWidget.setTooltip(#rows > 0 and rows or "No Claude agents")
end

local function finish(list)
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
    local list, pending = {}, #roster
    if pending == 0 then return finish(list) end
    for i, a in ipairs(roster) do
      local entry = { id = a.id, name = tostring(a.name or a.id or "?"), state = tostring(a.state or ""), startedAt = a.startedAt, haiku = "" }
      list[i] = entry
      local path = noctalia.expandPath(`~/.claude/jobs/{a.id}/state.json`)
      noctalia.readFileAsync(path, function(contents)
        local job = contents and noctalia.json.decode(contents) or nil
        if type(job) == "table" then entry.haiku = haiku(job.detail) end
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
