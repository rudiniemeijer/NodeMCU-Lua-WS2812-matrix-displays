# 39x5 display
## Introduction
This 39x5 matrix display consists of 5 strings of 39 WS2812B leds, of which the last one of each (minus the last) row is connected to the first one of the next row. A string of WS2812B leds is addressed with a sequential number in the range (1, number of WS2812B leds in the string). The basic addressing code is contained in the [`ws2812display.lua`](ws2812display.lua) file. A 3x5 font is available in [`tomthumbfont.lua`](tomthumbfont.lua) and a complete demonstration program is available in [`39x5-display.lua`](39x5-display.lua).

## Required firmware modules
In order to run the demonstration program, the following modules are needed: bit, file, gpio, http, net, node, rtctime, sntp, tmr, uart, wifi, ws2812. A suitable firmware is available here.
