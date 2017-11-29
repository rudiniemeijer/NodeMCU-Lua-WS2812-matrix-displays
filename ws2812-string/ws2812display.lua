-- WS2812 RGB led strip display
-- Copyright (c) 2017 Rudi Niemeijer
-- Display routines ontleend aan https://github.com/rudiniemeijer/NodeMCU-Lua-WS2812-matrix-displays
-- MIT License
--
-- Werkt met WS2812 led strips die in rijen onder elkaar zijn opgesteld
-- Laatste led van iedere rij is verbonden met de eerste led van de volgende rij
--
-- DIN van eerste led is aangesloten op NodeMCU/ESP-01 op D4/GPIO2
-- Coordinaatsysteem loo van (1,1) in de linkeronderhoek

displayWidth = 39
displayHeight = 5

ws2812.init(ws2812.MODE_SINGLE) -- D4/GPIO2
leds = displayWidth * displayHeight
disp = ws2812.newBuffer(leds, 3) -- Display buffer with 3 colors fixed

------------------------------------------------------------------------------------------
-- Derived/copied from https://github.com/rudiniemeijer/NodeMCU-Lua-WS2812-matrix-displays
------------------------------------------------------------------------------------------
-- Set brightness of all displays
brightness = 1 -- 1..255, note that color depth decreases with brightness

------------------------------------------------------
-- High level pixel manipulation                    --
-- For all functions goes: Origin (1,1) is top-left --
-- clear()                                          --
-- plot(x, y, hue)                                  --
-- unplot(x, y)                                     --
-- isset(x, y)                                      --
-- line(x0, y0, x1, y1, hue)                        --
-- circle(x0, y0, radius, hue)                      --
-- repaint()                                        --
-- autoRepaint(fps)                                 --
------------------------------------------------------
function clear() -- Clear the display buffer
  disp:fill(0, 0, 0) -- clear buffer
end

function plot(x, y, hue) -- Set a led at x, y with color hue
  if (x >= 1) and (x <= displayWidth) and (y >= 1) and (y <= displayHeight) then
    plotPos = toLineair(x, y)
    disp:set(plotPos, hueToRGB(hue))
  end
end

function unplot(x, y) -- Un-set a led at x, y
  plot(x, y, -1)
end

function isset(x, y) -- Return true if pixel at x, y is set, otherwise false
  if (x >= 1) and (x <= displayWidth) and (y >= 1) and (y <= displayHeight) then
    a, b, c = disp:get(toLineair(x, y))
  else
    a, b, c = 0, 0, 0
  end
  if a + b + c > 0 then
    return true
  else
    return false
  end
end

-- Functions line and circle use Bresenham's integer alorithms
-- See https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

--[[
function line(x0, y0, x1, y1, hue) -- Draw a line from x0, y0 to x1, y1 with color hue
  dx = x1 - x0
  dy = y1 - y0
  dx1 = math.abs(dx)
  dy1 = math.abs(dy)
  px = 2 * dy1 - dx1
  py = 2 * dx1 - dy1
  if dy1 <= dx1 then
    if dx >= 0 then
      x = x0
      y = y0
      xe = x1
    else
      x = x1
      y = y1
      xe = x0
    end
    plot(x, y, hue)

    while x < xe do
      x = x + 1
      if px < 0 then
        px = px + 2 * dy1
      else
        if (dx < 0 and dy < 0) or (dx > 0 and dy > 0) then
          y = y + 1
        else
          y = y - 1
        end
        px = px + 2 * (dy1 - dx1)
      end
      plot(x, y, hue)
    end
  else
    if dy >= 0 then
      x = x0
      y = y0
      ye = y1
    else
      x = x1
      y = y1
      ye = y0
    end
    plot(x, y, hue)

    while y < ye do
      y = y + 1
      if py <= 0 then
        py = py + 2 * dx1
      else
        if (dx < 0 and dy < 0) or (dx > 0 and dy > 0) then
          x = x + 1
        else
          x = x - 1
        end
        py = py + 2 * (dx1 - dy1)
      end
      plot(x, y, hue)
    end
  end
end

function circle(x0, y0, radius, hue) -- Plot a circle at x0, y0 with radius and color hue
  x, y = radius, 0
  radiusError = 1 - x
  while (x >= y) do
    plot ( x + x0,  y + y0, hue)
    plot ( y + x0,  x + y0, hue)
    plot (-x + x0,  y + y0, hue)
    plot (-y + x0,  x + y0, hue)
    plot (-x + x0, -y + y0, hue)
    plot (-y + x0, -x + y0, hue)
    plot ( x + x0, -y + y0, hue)
    plot ( y + x0, -x + y0, hue)
    y = y + 1
    if (radiusError < 0) then
      radiusError = radiusError + (2 * y + 1)
    else
      x = x - 1
      radiusError = radiusError + 2 * (y - x) + 1
    end
  end
end
]]--

-------------------------------
-- Color conversion routines --
-------------------------------
function hueToRGB(h) -- Convert floating point hue to integer R, G, B
  if h <= 0 then
    r, g, b = 0, 0, 0
  elseif h >= 1 then
    r, g, b = 1, 1, 1
  else
    if h < 1 / 3 then
      r = 2 - h * 6
      g = h * 6
      b = 0
    elseif h < 2 / 3 then
      r = 0
      g = 4 - h * 6
      b = h * 6 - 2
    else
      r = h * 6 - 4
      g = 0
      b = (1 - h) * 6
    end
  end
  if r > 1 then
    r = 1
  end
  if g > 1 then
    g = 1
  end
  if b > 1 then
    b = 1
  end
  r = r * brightness
  g = g * brightness
  b = b * brightness
  return string.char(r, g, b)
end

------------------------------------------------------
-- Convert from orthogonal coordinates to led strip --
------------------------------------------------------
function toLineair(x, y)
  linPos = (y - 1) * displayWidth + x
  return linPos
end

-------------------------------------------------
-- Low level display initialisation and update --
-------------------------------------------------
function initDisplay()
  disp:fill(0, 0, 0) -- clear buffer
  ws2812.write(disp) -- write buffer to display
end

function repaint()
  ws2812.write(disp) -- write buffer to display
end

function autoRepaint(fps)
  if fps > 0 then
    t = math.floor(1000 / fps)
    if (t < 10) or (t > 5000) then
      t = 1000 -- Default to once a second
    end
    tmr.alarm(6, t, tmr.ALARM_AUTO, repaint)
  else
    tmr.stop(6)
  end
end

initDisplay()
autoRepaint(0) -- disable autoRepaint, use repaint()
