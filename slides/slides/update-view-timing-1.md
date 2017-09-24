## Elm's update - view loop<br>and DOM rendering

<img alt="Elm pattern" src="resources/elm-pattern_s1800x0_q80_noupscale.png" style="height: 450px; border: none;">

note:
* Before we go on, I want to review the Elm uppdate - view loop a little bit. (Thanks to Ossi Hanhinen for this nice picture).
* As Elm cycles through it's Update - Model - View loop, it's important to know about the timing
of the rendering that takes place inside the view function. What happens in the Elm runtime is that
all the HTML or SVG elements specified in the view function are compared with the current state of
the DOM in the browser and the somewhat-magical virutal DOM is updated to match what you specified...

Image Credit:
* [Ossi Hanhinen: How Elm made our work better](http://futurice.com/blog/elm-in-the-real-world)
