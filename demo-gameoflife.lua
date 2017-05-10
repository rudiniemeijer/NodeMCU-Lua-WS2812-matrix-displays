-- Game of Life for WS2812 RGB Matrix Display
-- Copyright (c) 2017 Rudi Niemeijer

-- Requires the use of WS2812 plot functions
dofile("matrixutility.lc")
nextdisp = ws2812.newBuffer(leds, 3)

function setup(a)
  autoRepaint(-1)
  clear()
  if a == nil then 
    plot(10, 10, 1)
    plot(10, 11, 1)
    plot(11, 10, 1)
    plot(12, 10, 1)
  elseif a == "acorn" then
    plot(15, 9, 2)
    line(14, 11, 15, 11, 2)
    plot(17, 10, 2)
    line(18, 11, 20, 11, 2)
  elseif a == "r-pentomino" then
    line(16, 8, 17, 8, 2)
    line(15, 9, 16, 9, 2)
    plot(16, 10, 2)
  end
end

function st(x, y)
  if isset(x, y) then
    return 1
  else
    return 0
  end
end

function iterate()
  change = false
  for i = 1, displayWidth do
    for j = 1, displayHeight do
      neighbors = 
        st(i    , j + 1) +
        st(i    , j - 1) +
        st(i + 1, j    ) +
        st(i + 1, j + 1) +
        st(i + 1, j - 1) +
        st(i - 1, j    ) +
        st(i - 1, j + 1) +
        st(i - 1, j - 1) 

      if isset(i, j) then
        plot(i, j, 0.5)
        if neighbors < 2 then nextdisp:set(toLineair(i, j), {0,0,0}) end
        if neighbors == 2 or neighbors == 3 then nextdisp:set(toLineair(i, j), {0,1,0}) end -- lives on
        if neighbors > 3 then nextdisp:set(toLineair(i, j), {0,0,0}) end
      else
        if neighbors == 3 then
          nextdisp:set(toLineair(i, j), {1,0,0})
          change = true
        end -- born
      end
      tmr.wdclr()
    end
    repaint()
  end
  disp:replace(nextdisp)
  repaint()
  if change == false then
    tmr.stop(1)
    print("done.")
  end
end

setup("r-pentomino")
tmr.alarm(1, 5000, tmr.ALARM_AUTO, iterate)
