##  Custom alertSizes DOM event

```js
// port openAlertNextFrame : String -> Cmd msg
// Version that does not rely on using Elm subscriptions.
// Wait one paint cycle before calling dispatchAlertSizes,
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
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
