# NodeMCU/Lua WS2812 RGB Matrix displays
Lua program set for NodeMCU to drive cascaded 2x2, 4x4 or 8x8 WS2812 matrix displays. The program set is itself meant as a utility as well as an educational example of how to address matrix displays. The set consists of the following code:
* _matrixutility.lua_, a Lua program that fully contains all code to address a cascaded (interconnected) amount of WS2812 square matrix displays. It features a set of basic pixel manipulation routines, as well as an either manual or automated repaint of the display.

## WS2812 matrix displays
A WS2812 is an RGB led with an embedded controller that interfaces with one wire to a microprocessor. Furthermore, each WS2812 has the ability to daisychain to the next WS2812. Each WS2812 in such a daisychain is numbered from 1 to _number of WS2812s_. Strings of WS2812s are available, but also square and circle-shaped displays in which the WS2812s are connected in rows, whereby the end of each row each connected to the start of the next row. These displays thus consist of a string of WS2812s, numbered from top-left to bottom-right. The leds on an 8x8 display for example are numbered from 1 to 64. The leds on two interconnected 8x8 displays are numbered 1 to 128, where number 65 is the first led on the second display. Adressing each pixel orthogonally with an (x, y) coordinate on a set of WS2812 displays involves some calculations to determine which WS2812 on the large string of leds has to be fired on, which is exactly what _matrixutility.lua_ does.  

![WS2812 displays](https://github.com/rudiniemeijer/NodeMCU-Lua-WS2812-matrix-displays/blob/master/ws2812cascadeddisplays.jpg)

The test 'TEST' on the boards shown above is written to the display with the following Lua instruction: `plotstring("TEST", 2, 2, 0.7)`

## matrixutility.lua
A NodeMCU/Lua implementation that drives WS2812 matrix displays in the sizes 2x2, 4x4, 8x8 and up, solo or cascaded. Full color is supported and displays can be cascaded in any direction. Some basic pixel manipulation routines are implemented:  
* clear()
* plot(x, y, hue)
* unplot(x, y)
* isset(x, y)
* line(x0, y0, x1, y1, hue)
* circle(x0, y0, radius, hue)
* repaint()
* autoRepaint(fps)
* hueToRGB(hue)  
  
It is advised to save this file to the NodeMCU first, compile it to matrixutility.lc and then remove the matrixutility.lua. Include the routines in any other lua program with _dofile("matrixutility.lua")_.

## matrixtext.lua
This file contains a character map for a bold 8x8 dot matrix font. It has one function: to provide a Lua table with character information for a given ASCII character. This file is only needed if you want to use this font on the WS2812 displays. It requires the presence of _matrixutility.lc_, which is the compiled version of _matrixutility.lua_.
