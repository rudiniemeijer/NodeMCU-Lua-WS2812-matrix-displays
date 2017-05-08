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
boardsWide, boardsHigh = 2, 1 -- Matrix boards wide and high
boardWidth, boardHeight = 8, 8 -- Size of matrix boards (all boards must be same size, i.e. 4x4 or 8x8)
ledsPerBoard = boardWidth * boardHeight -- Number of leds per board, i.e. 16 or 64
displayWidth = boardsWide * boardWidth -- Leds horizontal
displayHeight = boardsHigh * boardHeight -- Leds vertical
ws2812.init(ws2812.MODE_SINGLE) -- D4/GPIO2
leds = boardsWide * boardsHigh * ledsPerBoard -- Total number of leds on the display
colors = 3 -- RGB si three colors
disp = ws2812.newBuffer(leds, colors) -- Display buffer
brightness = 3 -- 1..255

-------------
-- TESTING --
-------------
-- Center point and animation direction for circle
cX, cY = math.floor(displayWidth / 2), math.floor(displayHeight / 2); dirX, dirY = 1, 1

function testDisplay() -- Contains all testing code
  clear()
  -- plot(math.floor(node.random() * displayWidth) + 1, math.floor(node.random() * displayHeight) + 1, node.random())

  -- Test circle by moving it around on the screen and having it bounce off the edges
  r = 1
  circle(cX, cY, r, 0.8)
  if dirX == 1 then
    if cX + 1 + r > displayWidth then
      dirX = 0
    else
      cX = cX + 1
    end
  else
    if cX - 1 - r < 1 then
      dirX = 1
    else
      cX = cX - 1
    end
  end
  if dirY == 1 then
    if cY + 1 + r > displayHeight then
      dirY = 0
    else
      cY = cY + 1
    end
  else
    if cY - 1 - r < 1 then
      dirY = 1
    else
      cY = cY - 1
    end
  end

  -- Test line routine
  -- Plot a cross in the center of module 1
  line(2, 2, 7, 7, 0.3)
  line(2, 7, 7, 2, 0.3)

  -- Test coordinate system
  -- Plot a pixel on each of the four corners
  plot(1, 1, 0.5)
  plot(1, displayHeight, 0.5)
  plot(displayWidth, 1, 0.5)
  plot(displayWidth, displayHeight, 0.5)
end

------------------------------------------------------
-- High level pixel manipulation                    --
-- For all functions goes: Origin (1,1) is top-left --
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

function line(x0, y0, x1, y1, hue) -- Draw a line from x0, y0 to x1, y1 with color hue
  dx = x1 - x0
  if dx < 0 then
    dx = x0 - x1
    x0 = x1
    x1 = x0 + dx
  end
  dy = y1 - y0
  if dy < 0 then
    dy = y0 - y1
    y0 = y1
    y1 = y0 
    y1 = y0 + dy
  end
  D = 2 * dy - dx
  plot(x0, y0, hue)
  y = y0
  for x = x0 + 1, x1 do
    if D > 0 then
      y = y + 1
      plot(x, y, hue)
      D = D + (2 * dy - 2 * dx)
    else
      plot(x, y, hue)
      D = D + (2 * dy)
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

----------------------------
-- Text handling routines --
----------------------------
function write(text, x, y, hue) -- Write a text at upperleft position x, y
end

function charTable(c) -- Return a table containing the character information
  rc = {}
  if c == '0' then rc = {0x00,0x1e,0x33,0x33,0x33,0x33,0x33,0x1e} end
  if c == '1' then rc = {0x00,0x3f,0x0c,0x0c,0x0c,0x0c,0x0f,0x0c} end
  if c == '2' then rc = {0x00,0x3f,0x06,0x0c,0x18,0x30,0x33,0x1e} end
  if c == '3' then rc = {0x00,0x1e,0x31,0x30,0x1e,0x30,0x31,0x1e} end
  if c == '4' then rc = {0x00,0x30,0x30,0x7f,0x33,0x32,0x34,0x38} end
  if c == '5' then rc = {0x00,0x1e,0x31,0x30,0x30,0x1f,0x03,0x3f} end
  if c == '6' then rc = {0x00,0x1e,0x33,0x33,0x1f,0x03,0x23,0x1e} end
  if c == '7' then rc = {0x00,0x03,0x06,0x0c,0x18,0x30,0x33,0x3f} end
  if c == '8' then rc = {0x00,0x1e,0x33,0x33,0x1e,0x33,0x33,0x1e} end
  if c == '9' then rc = {0x00,0x1e,0x33,0x30,0x3e,0x33,0x33,0x1e} end
  return rc
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
autoRepaint(20) -- 10 frames per second
tmr.alarm(2, 100, tmr.ALARM_AUTO, testDisplay) -- 2 fps
