-- Matrix Text for WS2812 RGB Matrix Display
-- Copyright (c) 2017 Rudi Niemeijer
dofile("matrixutility.lc")

dofile("tomthumbfont.lua")
function plotchar3x5(c, x, y, hue) -- Plot character c 3x5 bits at x, y in hue
  for i = 1, 5 do
    for j = 1, 3 do
      if bit.isset(c[i], 3 - j) then
        plot(x + j - 1, y + i - 1, hue)
      else
        unplot(x + j - 1, y + i - 1)
      end
    end
    tmr.wdclr()
  end
end

function plotstring3x5(s, x, y, hue) -- Plot a string of characters at x, y in hue
  for i = 1, #s do
    -- if x + ((i - 1) * 8) >= -7 and x + ((i - 1) * 8) <= displayWidth then
    plotchar3x5(getCharData3x5(string.sub(s, i, i)), x + ((i - 1) * 4), y, hue) 
  end
end



function plotchar8x8(c, x, y, hue) -- Plot character c 8x8 bits at x, y in hue
  for i = 1, 8 do
    for j = 1, 8 do
      if bit.isset(c[i], 8 - j) then
        plot(x + j - 1, y + i - 1, hue)
      else
        unplot(x + j - 1, y + i - 1)
      end
    end
    tmr.wdclr()
  end
end

function plotstring8x8(s, x, y, hue) -- Plot a string of characters at x, y in hue
  for i = 1, #s do
    -- if x + ((i - 1) * 8) >= -7 and x + ((i - 1) * 8) <= displayWidth then
    plotchar8x8(getCharData8x8(string.sub(s, i, i)), x + ((i - 1) * 8), y, hue) 
  end
end

function test()
  clear()
  plotstring8x8("Time", 1, 9, 0.3)
  line(1, 7, 32, 7, 0.1)
  plotstring3x5("01:23", 1, 4, 0.7)
end

--tmr.alarm(1, 10, tmr.ALARM_SINGLE, test8x8)
test()
