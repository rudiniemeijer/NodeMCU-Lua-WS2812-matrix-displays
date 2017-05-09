-- Text display for WS2812 RGB Matrix Display
-- Copyright (c) 2017 Rudi Niemeijer

-- Requires the use of WS2812 plot functions and charset
dofile("matrixutility.lc")
dofile("matrixtext.lc")

-- !!!!
-- These functions must eventually reside in matrixtext.lc
function plotchar(c, x, y, hue) -- Plot character c 8x8 bits at x, y in hue
  for i = 1, 8 do
    for j = 1 to 8 do
      if bit.isset(c[i], j) then
        plot(x + j - 1, y + i - 1, hue)
      else
        unplot(x + j - 1, y + i - 1)
      end
    end
    tmr.wdclr()
  end
end

function plotstring(s, x, y, hue) -- Plot a string of characters at x, y in hue
  for i = 1 to #s do
    plotchar(s[i], x + ((i - 1) * 8), y, hue)  
  end
end

-- Testing
plotchar(getchar('0'), 1, 1, 0.2)
plotstring("abc", 5, 4, 0.7)
