# NodeMCU/Lua WS2812 RGB Matrix displays
Lua program set for NodeMCU to drive cascaded 2x2, 4x4 or 8x8 WS2812 matrix displays. The program set is itself meant as a utility as well as an educational example of how to address matrix displays. The set consists of the following code:
* matrixutility.lua, a Lua program that fully contains all code to address a cascaded (interconnected) amount of WS2812 square matrix displays. It features a set of basic pixel manipulation routines, as well as an either manual or automated repaint of the display.

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
