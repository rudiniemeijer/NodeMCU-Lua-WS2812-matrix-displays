-- Text display for WS2812 RGB Matrix Display
-- Copyright (c) 2017 Rudi Niemeijer

-- Requires the use of WS2812 plot functions and charset
dofile("matrixutility.lc")
-- dofile("matrixtext.lc")

-- !!!!
-- These functions must eventually reside in matrixtext.lc
function plotchar(c, x, y, hue) -- Plot character c 8x8 bits at x, y in hue
  for i = 1, 8 do
    for j = 1, 8 do
      if bit.isset(c[j], i - 1) then
        plot(x + j - 1, y + i - 1, hue)
      else
        unplot(x + j - 1, y + i - 1)
      end
    end
    tmr.wdclr()
  end
end

function plotstring(s, x, y, hue) -- Plot a string of characters at x, y in hue
  for i = 1, #s do
    if x + ((i - 1) * 8) >= -7 and x + ((i - 1) * 8) <= displayWidth then
      plotchar(getCharData(string.sub(s, i, i)), x + ((i - 1) * 8), y, hue) 
    end
  end
end

-- Testing
brightness = 25
--plotchar(getCharData('a'), 1, 1, 0.1) -- Plot a single zero at upper left corner
--plotchar(getCharData('0'), 9, 1, 0.4) -- Plot a single zero at upper left corner
--plotchar(getCharData('Z'), 17, 1, 0.7) -- Plot a single zero at upper left corner

plotstring("TEST", 2, 2, 0.7)
ps = "07:42 abcd #$@! XYZ 01234"
tx = 1

function testText()
  -- clear()
  plotstring(ps, tx, 10, 1) -- plot the text
  tx = tx - 1
  if tx < -1 * #ps * 8 then
    tx = displayWidth + 1
  end
end

tmr.alarm(1, 1000, tmr.ALARM_AUTO, testText)
