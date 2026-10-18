--!nonstrict
-- Wide popup listing every Claude background agent: state, name, 3-word summary, age.
-- Data is published by status.luau to the plugin's shared state ("agents").

local STATE_COLOR = { working = "primary", done = "on_surface_variant" }

local function age(startedAt)
  if type(startedAt) ~= "number" then return "" end
  local mins = math.floor((noctalia.nowMs() - startedAt) / 60000)
  if mins < 60 then return `{mins}m` end
  return `{math.floor(mins / 60)}h{mins % 60}m`
end

local function row(a)
  local color = STATE_COLOR[a.state] or "error"
  return ui.row({ gap = 16, align = "center", paddingV = 4 }, {
    ui.label({ text = "●", color = color, width = 14 }),
    ui.label({ text = a.state, color = color, width = 80 }),
    ui.label({ text = a.name, color = "on_surface", flexGrow = 1 }),
    ui.label({ text = a.haiku or "", color = "on_surface_variant", width = 220 }),
    ui.label({ text = age(a.startedAt), color = "on_surface_variant", width = 56 }),
  })
end

local function render(agents)
  local rows = {}
  for _, a in ipairs(agents or {}) do
    table.insert(rows, row(a))
  end
  if #rows == 0 then
    table.insert(rows, ui.label({ text = "No Claude agents", color = "on_surface_variant" }))
  end
  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = "center", justify = "space_between" }, {
      ui.label({ text = "Claude agents", fontSize = 16, fontWeight = "bold", color = "on_surface" }),
      ui.button({ glyph = "close", onClick = function() panel.close() end }),
    }),
    ui.scroll({ flexGrow = 1, gap = 4 }, rows),
  }))
end

render(noctalia.state.get("agents"))
noctalia.state.watch("agents", render)
