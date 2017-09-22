##  Dispatching the &ldquo;alertSizes&rdquo; DOM event

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

note:
* Now, let's track the flow of data when we want to display an alert.
* First, the hidden heights of the alert's content elements have to be calculated, so that
we can set up the end state of the transition.
* Since we don't have a "click" or "focus" event that we can catch on the Elm side, we will still
use a port, but the only thing the port will do is dispatch a custom DOM event on the outermost
wrapper element of our HTML structure. We'll name the type of this custom event "alertSizes".
* We could use the JavaScript port to give us the <code>offsetHeight</code> values of the
alert's content elements, but in a few slides we'll see how we can get these values with Elm.
* Here's the code. It's pretty simple.
