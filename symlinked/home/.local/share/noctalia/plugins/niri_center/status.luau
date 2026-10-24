--!nonstrict
-- niri focus alignment in the bar: centered icon when niri's config has
-- center-focused-column "always", left-aligned icon otherwise.
-- Left click (or Mod+Shift+C in niri) runs niri/toggle-center.sh.

local CONFIG = noctalia.expandPath("~/.config/niri/config.kdl")
local TOGGLE = noctalia.expandPath("~/.config/niri/toggle-center.sh")

local centered = nil -- nil until the first read

local function render()
  local on = centered == true
  barWidget.render(ui.glyph({
    name = on and "layout-align-center" or "layout-align-left",
    size = 18,
    color = on and "primary" or "on_surface_variant",
  }))
  barWidget.setTooltip(on and "niri: focused window centered (click for left-aligned)"
    or "niri: focused window left-aligned (click to center)")
end

local function refresh()
  -- grep, not a Luau pattern: scanning the 30KB config in-script blows the CPU budget.
  noctalia.runAsync({ "grep", "-qE", '^\\s*center-focused-column "always"', CONFIG }, function(result)
    local now = result.exitCode == 0
    if now ~= centered then
      centered = now
      render()
    end
  end)
end

-- Polling is the fallback for hand edits; toggles ping onIpc for an instant update.
noctalia.setUpdateInterval(1000)
refresh()

function update()
  refresh()
end

-- toggle-center.sh pings this right after it edits the config.
function onIpc(event)
  if event == "refresh" then refresh() end
end

function onClick()
  -- Flip the icon now; the toggle's ping confirms it a moment later.
  centered = not centered
  render()
  noctalia.runAsync({ TOGGLE }, function() refresh() end)
end
