-- Tests for WS2812 RGB Matrix Display
-- Copyright (c) 2017 Rudi Niemeijer

-- Requires the use of WS2812 plot functions and charset
dofile("matrixutility.lc")
-- dofile("matrixtext.lc")

centerX = displayWidth / 2
centerY = displayHeight / 2
cX, cY = centerX, centerY

function testDisplay() -- Contains all testing code
  clear()
  brightness = 1
  -- plot(math.floor(node.random() * displayWidth) + 1, math.floor(node.random() * displayHeight) + 1, node.random())

  -- Test circle by moving it around on the screen and having it bounce off the edges
  r = 2
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
  -- Plot a cross in the center
  line(centerX - 2, centerY - 2, centerX + 3, centerY + 3, 0.3)
  line(centerX - 2, centerY + 3, centerX + 3, centerY -2, 0.3)

  -- Test coordinate system
  -- Plot a pixel on each of the four corners
  plot(1, 1, 0.5)
  plot(1, displayHeight, 0.5)
  plot(displayWidth, 1, 0.5)
  plot(displayWidth, displayHeight, 0.5)
end

tmr.alarm(1, 100, tmr.ALARM_AUTO, testDisplay)
