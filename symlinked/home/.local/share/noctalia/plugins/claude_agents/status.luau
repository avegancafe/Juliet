--!nonstrict
-- Claude Code background agents, summarised from `claude agents --json`.
--   robot glyph + "N" working; colour escalates: idle < working < needs input.
--   Left click: open the agents dashboard in a terminal.
-- Each agent's `state` is "working" or "done"; any other non-idle state
-- (e.g. needs input / blocked) is counted as needing attention.

local POLL_MS = 5000

local function classify(agents)
  local working, attention, done = 0, 0, 0
  local rows = {}
  for _, a in ipairs(agents) do
    local s = tostring(a.state or "")
    if s == "working" then
      working += 1
    elseif s == "done" then
      done += 1
    else
      attention += 1
    end
    table.insert(rows, { key = s, value = tostring(a.name or a.id or "?") })
  end
  return working, attention, done, rows
end

local function render(working, attention, done, rows)
  local total = working + attention + done
  if total == 0 then
    barWidget.setGlyph("robot")
    barWidget.setGlyphColor("on_surface_variant")
    barWidget.setText("")
    barWidget.setTooltip("No Claude agents")
    return
  end
  barWidget.setGlyph("robot")
  if attention > 0 then
    barWidget.setGlyphColor("error")
    barWidget.setColor("error")
  elseif working > 0 then
    barWidget.setGlyphColor("primary")
    barWidget.setColor("primary")
  else
    barWidget.setGlyphColor("on_surface")
    barWidget.setColor("on_surface")
  end
  barWidget.setText(`{working}/{attention}/{done}`)
  barWidget.setTooltip(rows)
end

local function refresh()
  noctalia.runAsync({ "claude", "agents", "--json" }, function(result)
    if result.exitCode ~= 0 then
      barWidget.setGlyphColor("on_surface_variant")
      barWidget.setText("?")
      return
    end
    local agents = noctalia.json.decode(result.stdout)
    if type(agents) ~= "table" then return end
    render(classify(agents))
  end)
end

noctalia.setUpdateInterval(POLL_MS)
refresh()

function update()
  refresh()
end

function onClick()
  noctalia.runInTerminal("claude agents")
end
