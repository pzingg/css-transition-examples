##  The CSS <code>transition:</code> property

<img alt="A CSS transition example" src="resources/css_transition_with_timing_function.png" style="height: 150px; border: none;">

<pre><code class="css" data-trim data-noescape>transition: &lt;property&gt; &lt;duration&gt; &lt;timing-function&gt; &lt;delay&gt;;

.animated-box {
    width: 100px;
    height: 100px;
    background-color: #0000FF;
    transition: width 2s ease-in-out,
        height 2s ease-in-out,
        background-color 2s ease-in-out 100ms;
}
</code></pre>

<pre class="fragment"><code class="text" data-trim data-noescape>
transitionrun -> transitionstart -> transitionend / transitioncancel
</code></pre>

note:
* Why use CSS transition for animations?
* No animation math calcs, no Cmd or Sub required in your Elm program, all you need is a set of initial values and
a set of final, target values.
* Assuming you have not specified a transition delay, the transition will kick in and begin interpolating
between the initial values and the changed computed values as soon as a "style change event"
is detected by the browser.
* The timing function then interpolates from initial values to target values
* When each transition animation reaches its target value, browser dispatches a transitionend event

Image credits:
* https://developer.mozilla.org/files/4529/TransitionsPrinciple.png

Resources:
* [CSS Transitions Working Draft](https://drafts.csswg.org/css-transitions/)
