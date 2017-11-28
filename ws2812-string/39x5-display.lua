dofile("ws2812display.lua")
dofile("tomthumbfont.lua")

brightness=25
clear()
task = "time"

function plotchar3x5(c, x, y, hue) -- Plot character c 3x5 bits at x, y in hue
  for i = 1, 5 do
    for j = 1, 3 do
      if bit.isset(c[i], 3 - j) then
        plot(x + j - 1, y + (5 - i +1) - 1, hue)
      else
        unplot(x + j - 1, y + (5 - i +1) - 1)
      end
    end
    tmr.wdclr()
  end
end

function plotstring3x5(s, x, y, hue) -- Plot a string of characters at x, y in hue
  for i = 1, #s do
    plotchar3x5(getCharData3x5(string.sub(s, i, i)), x + ((i - 1) * 4), y, hue) 
  end
end

function display()
  if task == "time" then
    local tm = rtctime.epoch2cal(rtctime.get())
    -- print(string.format("%02d-%02d-%04d %02d:%02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"], tm["sec"]))
    dstHour = tm["hour"] + 1
    if dstHour > 23 then
      dstHour = 0
    end
    timeStr = dstHour .. ":" .. string.format("%02d", tm["min"])
    print(timeStr)
    clear()
    -- plotstring3x5("Tijd", 1, 1, 0.1)
    plotstring3x5("T", 1, 1, node.random())
    plotstring3x5("I", 5, 1, node.random())
    plotstring3x5("J", 9, 1, node.random())
    plotstring3x5("D", 13, 1, node.random())
    plotstring3x5(timeStr, 20, 1, 1)
  end
  repaint()
end

sntp.sync(nil, nil, nil, 1)
autoRepaint(0)
tmr.alarm(1, 10000, tmr.ALARM_AUTO, display)
