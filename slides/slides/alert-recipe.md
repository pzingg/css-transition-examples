##  CSS transition Alert recipe

<ul>
<li class="fragment">HTML structure
<li class="fragment">CSS
<li class="fragment">Elm model state
<li class="fragment">Decoding content height - firing DOM event
<li class="fragment">Decoding content height - JSON decoder
<li class="fragment">Elm <code>view</code> helpers
<li class="fragment"><code>view</code> function with event handlers
<li class="fragment">Elm <code>update</code> function
</ul>

note:
So how do we put this all together to animate the alert example?

We need all these pieces:
* A well-defined HTML DOM tree so we can query the height of content that will be animated
* Associated styles in CSS that include the transition property
* Elm types that can represent the visibility state of the widget
* Some way to probe the target content height (preferably in Elm)
* A view function that will set the initial and target heights
* An update function that will respond to programmer and end-user actions and visibility state changes
