## Timing is everything

<img alt="Elm pattern" src="resources/elm-pattern_s1800x0_q80_noupscale.png" style="height: 300px; border: none;">

<ul>
<li class="fragment">`requestAnimationFrame` in a JavaScript port
<li class="fragment">Elm Sub with an `InitialRender` visibility state
<li class="fragment">`Process.sleep` Task
</ol>

note:
* Sometimes our code wants to render a new tree and start the animation as soon as possible.
* For the animation to work, you have to make sure that the initial state is rendered on the VDOM for at least one cycle.
* In the info box example, special timing is not necessary, because the content is always on the VDOM, and we just
wait for a user click to render the target height value.
* In the alert example, we needed a port to dispatch a custom DOM event, so we can take advantage
of JavaScript's `requestAnimationFrame`, which we saw in a previous slide
* But we could also have waited for an initial render on the Elm side by adding one more tag,
called `InitialRender`, to our visibility type, and then use a Sub from the `AnimationFrame`
module to let us know when the view has been rendered with the initial (zero) height value.
* In the page transition example, we use the `Process.sleep` technique, and just delay the beginning of the
animation by 100 milliseconds.

Image Credit:
* [Ossi Hanhinen: How Elm made our work better](http://futurice.com/blog/elm-in-the-real-world)
