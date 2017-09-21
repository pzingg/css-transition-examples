##  Custom &ldquo;alertSizes&rdquo; DOM event

<pre class="fragment"><code class="js" data-trim data-noescape>// Dispatch a DOM custom event for Elm to handle.
function dispatchAlertSizes(domId) {
    var wrapper = document.getElementById(domId);
    if (wrapper) {
        var event = new CustomEvent('alertSizes',
          { 'bubbles': true, 'cancelable': false });
        wrapper.dispatchEvent(event);
    }
}
</code></pre>

<pre class="fragment"><code class="js" data-trim data-noescape>// port openAlertNextFrame : String -> Cmd msg
// Version that does not rely on using Elm subscriptions.
// Wait one render cycle before calling dispatchAlertSizes,
// so that DOM is set up first.
app.ports.openAlertNextFrame.subscribe(function(domId) {
    var boundFunction = dispatchAlertSizes.bind(null, domId);
    <mark>window.requestAnimationFrame(boundFunction);</mark>
});

note:
* Now, let's track the flow of data when we want to display an alert.
* First, the hidden heights of the alert's content elements have to be calculated, so that
we can set up the end state of the transition.
* We could use a JavaScript port to give us the height values, but let's see how we can do it
with Elm.
* Since we don't have a "click" or "focus" event that we can catch on the Elm side, we will still
use a port, but the only thing the port will do is dispatch a custom DOM event on the outermost
wrapper element of our HTML structure. We'll name the type of this custom event "alertSizes".
* Here's the code. It's pretty simple.
* The only subtlety is that since we're calling this port from our Elm update function, potentially before the
DOM tree for our alert has been rendered onto the virtual DOM, we will use `requestAnimationFrame` to delay
the event dispatch process for one render cycle so that the wrapper element will actually be found in the document.
* We'll see some other ways to deal with these timing issues later, but since we already have to resort to
port to do this work, `requestAnimationFrame` is a straightforward technique here.
