-- WS2812 matrix display utility program
-- Copyright (c) 2017 Rudi Niemeijer
--
-- Works with square WS2812 matrix displays in the sizes 2x2, 4x4, 8x8 etc.
-- Configurable number of cascaded boards
-- 
-- Connect NodeMCU/EPS-01 with D4/GPIO2 to DIN of first WS2812 board
-- cascade other boards through DOUT/DIN
--
-- Six boards are connected as follows:
--   D4/GPIO2 -> 1 -> 2 -> 3 ->
--               4 -> 5 -> 6
-- Coordinate system runs from (1,1) in upper-left corner

----------------------------
-- Hardware configuration --
----------------------------
boardsWide, boardsHigh = 4, 2 -- Matrix boards wide and high
boardWidth, boardHeight = 8, 8 -- Size of matrix boards (all boards must be same size, i.e. 4x4 or 8x8)
ledsPerBoard = boardWidth * boardHeight -- Number of leds per board, i.e. 16 or 64
displayWidth = boardsWide * boardWidth -- Leds horizontal
displayHeight = boardsHigh * boardHeight -- Leds vertical
ws2812.init(ws2812.MODE_SINGLE) -- D4/GPIO2
leds = boardsWide * boardsHigh * ledsPerBoard -- Total number of leds on the display
disp = ws2812.newBuffer(leds, 3) -- Display buffer with 3 colors fixed

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
  disp:set(toLineair(x, y), {0,0,0})
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

-------------------------------
-- Color conversion routines --
-------------------------------
function hueToRGB(h) -- Convert floating point hue to integer R, G, B
  local r, g, b = 0, 0, 0

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

------------------------------------------------
-- Convert from and to orthogonal coordinates --
------------------------------------------------
function toLineair(x, y)
  boardNumber = math.floor((y - 1) / boardHeight) * boardsWide + math.floor((x - 1) / boardWidth)
  boardX = x - math.floor((x - 1) / boardWidth) * boardWidth
  boardY = y - math.floor((y - 1) / boardHeight) * boardHeight
  linPos = boardNumber * ledsPerBoard + (boardY - 1) * boardHeight + boardX
  --print("x="..x..", y="..y..", board="..boardNumber..", bX="..boardX..", bY="..boardY..", pos="..linPos)
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
  t = math.floor(1000 / fps)
  if (t < 10) or (t > 5000) then
    t = 1000
  end
  tmr.alarm(6, t, tmr.ALARM_AUTO, repaint)
end

initDisplay()
autoRepaint(20) -- 20 frames per second
--tmr.alarm(1, 100, tmr.ALARM_AUTO, testDisplay)
