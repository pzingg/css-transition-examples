## Timing is everything



<ol>
<li class="fragment">Use `requestAnimationFrame` in a JavaScript port
<li class="fragment">Use Elm Subs with an `InitialPaint` visibility state
<li class="fragment">Use `Process.sleep` Task to wait 100 to 200 milliseconds
</ol>

note:
* Sometimes our code wants to paint a new tree and start the animation as soon as possible.
* For the animation to work, you have to make sure that the initial state is painted on the VDOM for at least one cycle.
* In the info box example, special timing is not necessary, because the content is always on the VDOM, and we just
wait for a user click to paint the target height value.
* In the alert example, we needed a port to dispatch a custom DOM event, so we can take advantage
of JavaScript's <code>requestAnimationFrame</code>, which we saw in a previous slide
* But we could also have waited for an initial paint on the Elm side by adding one more tag, called <code>InitialPaint</code,
to our visibility type, and then using a Sub from the <code>AnimationFrame</code> module to let us know when
the view has been painted with the initial (zero) height value.
* In the page transition example, we use the <code>Process.sleep</code> technique, and just delay the beginning of the
animation by 100 milliseconds.
