## Elm's update - view loop<br>and DOM rendering

<img alt="Elm pattern" src="resources/elm-pattern_timing.png" style="height: 450px; border: none;">

note:
* But this rendering (you can explore the code at elm-lang/virtual-dom if you're curious) is
scheduled to happen at the next browser "animation frame", so that the browser is not interrupted
with DOM updates at random times, and therefore everything happens smoothly.
* The impact of this scheduling for our alert widget is that we have to make sure that the
alert element has been rendered on the virtual DOM before we can dispatch an event on it.

Image Credit:
* [Ossi Hanhinen: How Elm made our work better](http://futurice.com/blog/elm-in-the-real-world)
