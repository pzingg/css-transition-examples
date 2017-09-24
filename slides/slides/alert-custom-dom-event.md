##  Opening the alert with an event

How can Elm handle an action when there's no "click" event?

<div class="fragment">With a <b>custom</b> event from JavaScript:

<pre><code class="js" data-trim data-noescape>// Dispatch a DOM custom event for Elm to handle.
function dispatchAlertSizes(domId) {
    var wrapper = document.getElementById(domId);
    if (wrapper) {
        var event = new CustomEvent('alertSizes',
          { 'bubbles': true, 'cancelable': false });
        <mark>wrapper.dispatchEvent(event);</mark>
    }
}
</code></pre>
</div>

note:
* Now that we've seen the basics of how we are going to set our initial and target height
values for the alert, let's follow the flow of data that happens when we open an alert.
* The actual, but hidden heights of the alert's content elements have to be found, so that
we can calculate the target height values.
* Since we don't have a "click" or "focus" event that we can catch on the Elm side, we will still
use an outgoing JavaScript port to create our own event.  We'll set the type of this custom event
to be "alertSizes".
* Here's the code to create and fire off the DOM event. It's pretty simple.
* We could also write some JavaScript in this port to give us the <code>offsetHeight</code>
values of the alert's content elements, but in a few slides we'll see how we can get these
values with Elm. I like doing as little JavaScript coding as possible, when there's an Elm
alternative.

Resources:
* [Elm and the DOM](https://medium.com/@debois/elm-the-dom-8c9883190d20)
