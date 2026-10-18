--!nonstrict
-- Wide popup listing every Claude session: die/state, bg|int, name, what it said or
-- needs (the agents-feed reason), context fill, age.
-- Data is published by status.luau to the plugin's shared state ("agents").

local STATE_COLOR = { working = "primary", done = "on_surface_variant" }

local function age(startedAt)
  if type(startedAt) ~= "number" then return "" end
  local mins = math.floor((noctalia.nowMs() - startedAt) / 60000)
  if mins < 60 then return `{mins}m` end
  return `{math.floor(mins / 60)}h{mins % 60}m`
end

-- One line, at most n characters (labels wrap otherwise and squeeze their neighbours).
local function clip(s, n)
  s = string.match(tostring(s or ""), "^[^\n]*") or ""
  if utf8.len(s) and utf8.len(s) > n then
    return string.sub(s, 1, utf8.offset(s, n) - 1) .. "…"
  end
  return s
end

local function row(a)
  local color = a.role or STATE_COLOR[a.state] or "error"
  return ui.row({ gap = 16, align = "center", paddingV = 4 }, {
    ui.label({ text = (a.die and a.die ~= "") and a.die or "●", color = color, width = 14 }),
    ui.label({ text = a.state, color = color, width = 70 }),
    ui.label({ text = if a.kind == "interactive" then "int" else "bg", color = "on_surface_variant", width = 28 }),
    ui.label({ text = clip(a.name, 34), color = "on_surface", width = 290 }),
    ui.label({ text = clip(a.reason, 64), color = "on_surface_variant", flexGrow = 1 }),
    ui.label({ text = if type(a.ctx) == "number" then `ctx {math.floor(a.ctx + 0.5)}%` else "", color = "on_surface_variant", width = 64 }),
    ui.label({ text = age(a.startedAt), color = "on_surface_variant", width = 56 }),
  })
end

local function render(agents)
  local rows = {}
  for _, a in ipairs(agents or {}) do
    table.insert(rows, row(a))
  end
  if #rows == 0 then
    table.insert(rows, ui.label({ text = "No Claude sessions", color = "on_surface_variant" }))
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
