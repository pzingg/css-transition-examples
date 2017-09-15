##  Custom &ldquo;alertSizes&rdquo; DOM event

<pre class="fragment"><code class="js" data-trim data-noescape>// port openAlertNextFrame : String -> Cmd msg
// Version that does not rely on using Elm subscriptions.
// Wait one render cycle before calling dispatchAlertSizes,
// so that DOM is set up first.
app.ports.openAlertNextFrame.subscribe(function(domId) {
    var boundFunction = dispatchAlertSizes.bind(null, domId);
    window.requestAnimationFrame(boundFunction);
});

// Dispatch a DOM custom event for Elm to handle
function dispatchAlertSizes(domId) {
    var wrapper = document.getElementById(domId);
    if (wrapper) {
        var event = new CustomEvent('alertSizes',
          { 'bubbles': true, 'cancelable': false });
        wrapper.dispatchEvent(event);
    }
}
</code></pre>

note:
* Now, let's get to our first dilemma.
* How can we calculate the hidden heights of these content elements so we can set up the end state of the transition?
* We could use a JavaScript port to give us the height values, but let's see how we can do it with Elm.
* We're going to be handling a DOM event that will be dispatched on the outermost wrapper element of our HTML structure.
* Since we don't have a "click" or "focus" event that we can latch onto, let's use a port to create and dispatch
a custom event.  We'll call it "alertSizes".
* Here's the code. It's pretty simple. We create an event with the type "alertSizes" and then dispatch it on the
wrapper element.
* The only subtlety is that since we're calling this port from our Elm update function, potentially before the
DOM tree for our alert has been "rendered" onto the virtual DOM, we will use <code>requestAnimationFrame</code> to delay
the event dispatch process for one render cycle so that the wrapper element will actually be found in the document.
* We'll see some other ways to deal with these timing issues later, but since we already have to resort to
port to do this work, <code>requestAnimationFrame</code> is a straightforward technique here.
