##  The <code>transition:</code> property

<img alt="A CSS transition example" src="resources/TransitionsPrinciple.png" style="height: 150px; border: none;">

<pre><code class="css">transition: &lt;property&gt; &lt;duration&gt; &lt;timing-function&gt; &lt;delay&gt;;
</code></pre>

<pre class="fragment"><code class="css">.box {
    width: 100px;
    height: 100px;
    background-color: #0000FF;
    transition: width 2s ease-in-out,
        height 2s ease-in-out,
        background-color 2s ease-in-out 100ms;
}
</code></pre>

note:
* Why use CSS transition for animations?
* You use the CSS transition property to create animations between an initial state of one or more properties and a final state
* No animation math calcs, no Cmd or Sub required in your Elm program, all you need is an initial value or set of values and
a target value or values.
* The transition property is composed of four sub-properties:

    * transition-property - height, width, top, opacity, visibility, color, transform, z-index, etc.
    * transition-duration - specify in seconds or milliseconds
    * transition-timing-function - linear, ease, ease-in, ease-out, ease-in-out,
    cubic-bezier(...), step-start, step-end, steps(...), frames(...)  
    * transition-delay - specify in seconds or milliseconds

* The full list of "animatable" (or preferred terminology "interpolation") properties is in the CSS Transitions spec,
Section 9. (See https://drafts.csswg.org/css-transitions/#animatable-properties)
* Basically any CSS or SVG property that is one of these types or a list of these types, can be interpolated:
    * integer
    * number
    * length
    * rectangle
    * percentage
    * font-weight
    * visibility
    * color

* Higher-level values such as "transform", which can be thought of as a list of numerical values can also be interpolated.
* More cool stuff. A transition property value can be calculated from percentages and lengths, using the "calc()"
specification from the CSS Values spec, like this (See https://drafts.csswg.org/css-values-4/#funcdef-calc):
    calc(100%/3 - 2*1em - 2*1px)


* Here's how it works: Just use your Elm view function to set the initial values of properties you want to animate, then set the target values
* The timing function then interpolates from initial values to target values
* When each transition animation reaches its target value, browser dispatches a transitionend event

Image credits:
* https://developer.mozilla.org/files/4529/TransitionsPrinciple.png
