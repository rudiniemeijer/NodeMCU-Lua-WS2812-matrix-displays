# NodeMCU/Lua WS2812 RGB Matrix displays
Lua program set for NodeMCU to drive cascaded 2x2, 4x4 or 8x8 WS2812 matrix displays. The program set is itself meant as a utility as well as an educational example of how to address matrix displays. The set consists of the following code:
* _matrixutility.lua_, a Lua program that fully contains all code to address a cascaded (interconnected) amount of WS2812 square matrix displays. It features a set of basic pixel manipulation routines, as well as an either manual or automated repaint of the display.

## WS2812 matrix displays
A WS2812 is an RGB led with embedded controller that interfaces with one wire to a microprocessor. Furthermore, each WS2812 has te ability to daisychain to the next WS2812. Each WS2812 in such a daisychain is numbered from 1 to _number of WS2812 modules_. Strings of WS2812 are available, but also square and circle-shaped displays. These displays consist of a string of WS2812 modules. The leds on an 8x8 display for example are numbered from 1 to 64. The leds on two interconnected 8x8 displays are numbered 1 to 128, where number 65 is the first led on the second display. Adressing each pixel orthogonally on a set of WS2812 displays involves some calculations, which is exactly what the matrixutility.lua does.  

![WS2812 displays](https://github.com/rudiniemeijer/NodeMCU-Lua-WS2812-matrix-displays/blob/master/ws2812cascadeddisplays.jpg)

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
