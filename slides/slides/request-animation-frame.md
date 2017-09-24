##  The openAlert JavaScript port

Waiting for an animation frame before dispatching the event:

<pre><code class="js" data-trim data-noescape>// port openAlertNextFrame : String -> Cmd msg
// Version that does not rely on using Elm subscriptions.
// Wait one render cycle before calling dispatchAlertSizes,
// so that DOM is set up first.
app.ports.openAlertNextFrame.subscribe(function(domId) {

    // Bind the domId parameter to the dispatchAlertSizes function
    var boundFunction = <mark>dispatchAlertSizes</mark>.bind(null, domId);

    // Call the bound function on the next animation frame
    <mark>window.requestAnimationFrame(boundFunction);</mark>
});
</code></pre>

note:
* Since we're already in JavaScript land, we use `requestAnimationFrame` to delay calling
that `dispatchAlertSizes` function we saw previously.  Now that function won't be called until
after our virtual DOM has been updated with all of the alert's elements, and the wrapper element
that dispatches the "alertSizes" event will actually be found in the document.
* There are other ways to deal with these timing issues on the Elm side,
but since we already have to resort to JavaScript for the custom DOM event anyway,
`requestAnimationFrame` is a straightforward technique here.
* If you want to see two other techniques (involving Elm subscriptions and delayed commands)
check out the sample code I have posted on GitHub.

Resources:
* [StackOverflow: Coordinating Rendering with Port Interaction](https://stackoverflow.com/questions/38952724/how-to-coordinate-rendering-with-port-interactions-elm-0-17)
