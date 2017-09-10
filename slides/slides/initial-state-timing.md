## Timing is everything

You have to make sure that the initial state is painted for
at least one cycle

<ol>
<li class="fragment">Use `requestAnimationFrame` in a JavaScript port
<li class="fragment">Use Elm Subs with an `InitialPaint` visibility state
<li class="fragment">Use `Process.sleep` Task to wait 100 to 200 milliseconds
</ol>

note:
    Sometimes our code wants to paint a new tree and start the animation as soon as possible.
    In the InfoBox example, not necessary, because we wait for a user click
    In the Alert example, we need a port to dispatch a custom DOM event, so we can take advantage
        of requestAnimationFrame, which we saw in a previous slide
    In the Page Transition example, we use the Process.sleep technique
