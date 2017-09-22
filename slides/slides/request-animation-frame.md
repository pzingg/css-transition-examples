##  Making sure the DOM is ready

<pre class="fragment"><code class="js" data-trim data-noescape>// port openAlertNextFrame : String -> Cmd msg
// Version that does not rely on using Elm subscriptions.
// Wait one render cycle before calling dispatchAlertSizes,
// so that DOM is set up first.
app.ports.openAlertNextFrame.subscribe(function(domId) {
    var boundFunction = dispatchAlertSizes.bind(null, domId);
    <mark>window.requestAnimationFrame(boundFunction);</mark>
});

note:
* We've only got one issue here. We have to make sure that the alert element has been rendered
on the virtual DOM before we can dispatch that event.
* We can use `requestAnimationFrame` to delay the event dispatch process for one browser
rendering cycle so we can make sure that the wrapper element will actually be found in the document.
* We'll see some other ways to deal with these timing issues later, but since we already have to resort to
port to do this work, `requestAnimationFrame` is a straightforward technique here.
