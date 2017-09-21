## Using DOM class to set target

<pre><code class="css" data-trim data-noescape>.carousel-inner > .item {
    transition: transform .6s ease-in-out;
}
</code></pre>

<div class="fragment">with additional classes that set initial and target values:
<pre><code class="css" data-trim data-noescape>.carousel-inner > .item<mark>.active</mark> {
    left: 0;
    transform: <mark>translate3d(0, 0, 0);</mark>
}

.carousel-inner > .item<mark>.active.left</mark> {
    left: 0;
    transform: <mark>translate3d(-100%, 0, 0);</mark>
}
</code></pre
</div>

note:
* An alternative method when the initial and target values do not have to be calculated is
to set them in CSS using more-specific class name selectors
* The initial state is set in this example by rendering the animated element with
the "item" and "active" class names, so the value of the transform property is (0, 0, 0)
* Then, to start the animated transition to the predefined target value of (-100%, 0, 0)
we render the element again with the class names of "item", "active", and "left".
