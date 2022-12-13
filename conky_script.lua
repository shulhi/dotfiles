require 'cairo'
require 'imlib2'

local cr, width, height, updates
local default, primary, warn, crit = 0x0787f0, 0x00bfa5, 0xfbc02d, 0xdd2c00
local	colors = {
        default = default,
        highlight = primary,
        gaugeBg = default,
        gaugeBgAlpha = 0.2,
        gauge = default,
        gaugeAlpha = 0.9,
        gaugeInfo = primary,
        gaugeWarn = warn,
        gaugeCrit = crit,
      }

function conky_main()
  if conky_window == nil or conky_window.width == 0 then return end
  local cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )

  cr = cairo_create(cs)
  width = conky_window.width
  height = conky_window.height

  updates=tonumber(conky_parse('${updates}'))

  updateBattery()

  cairo_destroy (cr)
  cairo_surface_destroy (cs)
  cr = nil
end

function updateBattery()
  local pos = {x = 2560, y = 0}

  local percentage = tonumber(conky_parse('${battery_percent BAT0}'))

  bar(cr, percentage, {
    thickness = 4,
    from = {x = pos.x, y = pos.y + 5},
    to = {x = 2560 - pos.x, y = pos.y + 5},
    background = { color = colors.gaugeBg, alpha = colors.gaugeBgAlpha },
    color = colors.gauge,
    alpha = colors.gaugeAlpha,
    warn = {to = 50, color = colors.gaugeWarn},
    crit = {to = 10, color = colors.gaugeCrit},
  })
end

function bar(cr, value, def)
  def.caps = def.caps or CAIRO_LINE_CAP_SQUARE

  if def.background then
    local bgDef = table.clone(def)
    bgDef.color = def.background.color
    bgDef.alpha = def.background.alpha
    line(cr, bgDef)
  end

  local t = value / 100
  if t > 1 then t = 1 end
  if t == 0.0 then return end
  def.to = {
    x = def.from.x + t * (def.to.x - def.from.x),
    y = def.from.y + t * (def.to.y - def.from.y),
  }

  if def.warn and (def.warn.from and def.warn.from <= value or def.warn.to and def.warn.to >= value) then
    def.color = def.warn.color
  end
  if def.crit and (def.crit.from and def.crit.from <= value or def.crit.to and def.crit.to >= value) then
    def.color = def.crit.color
  end
  line(cr, def)
end

function line(cr, def)
  local thickness = def.thickness or 10
  local color = def.color or 0xffffff
  local alpha = def.alpha or 1
  local caps = def.caps or CAIRO_LINE_CAP_BUTT

  cairo_set_line_width(cr, thickness)
  cairo_set_line_cap(cr, caps)
  cairo_set_source_rgba(cr, rgbToRgba(color, alpha))
  cairo_move_to(cr, def.from.x, def.from.y)
  cairo_line_to(cr, def.to.x, def.to.y)
  cairo_stroke(cr)
  cairo_new_path(cr) -- just to be sure
end

function table.clone(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[table.clone(orig_key)] = table.clone(orig_value)
    end
    setmetatable(copy, table.clone(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function rgbToRgba(color, alpha)
  return ((color / 0x10000) % 0x100) / 255.0,
  ((color / 0x100) % 0x100) / 255.0,
  (color % 0x100) / 255.0,
  alpha
end
