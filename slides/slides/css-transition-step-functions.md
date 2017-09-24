##  CSS transition step functions

<img src="resources/step.png" style="width: 300px; border: none">

<table class="mediumfont">
<tr><td colspan="2"> `steps(<integer>[, [ start | end ] ]?)` </td></tr>
<tr><td> `step-start` </td><td> `steps(1, start)` </td></tr>
<tr><td> `step-end` </td><td> `steps(1, end)` </td></tr>
</table>

note:
* `steps`: The first parameter specifies the number of intervals in the function. The second parameter,
which is optional, is either the value `start` or `end`, and specifies the point at which the
change of values occur within the interval. If the second parameter is omitted, it is given the value `end`.

* [CSS Transition Timing Function Spec](https://www.w3.org/TR/css3-transitions/#transition-timing-function-property)
