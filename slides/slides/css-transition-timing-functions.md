##  CSS transition bezier timing functions

<img src="resources/TimingFunction.png" style="width: 250px; border: none">

<table class="mediumfont">
<tr><td colspan="2"> `cubic-bezier(<number>, <number>, <number>, <number>)` </td></tr>
<tr><td> `linear` </td><td> `cubic-bezier(0, 0, 1, 1)` </td></tr>
<tr><td> `ease` </td><td> `cubic-bezier(0.25, 0.1, 0.25, 1)` </td></tr>
<tr><td> `ease-in` </td><td> `cubic-bezier(0.42, 0, 1, 1)` </td></tr>
<tr><td> `ease-out` </td><td> `cubic-bezier(0, 0, 0.58, 1)` </td></tr>
<tr><td> `ease-in-out` </td><td> `cubic-bezier(0.42, 0, 0.58, 1)` </td></tr>
</table>

note:
* `cubic-bezier`: The four parameters specify points P1 and P2 of the curve as (x1, y1, x2, y2).

* [CSS Transition Timing Function Spec](https://www.w3.org/TR/css3-transitions/#transition-timing-function-property)
