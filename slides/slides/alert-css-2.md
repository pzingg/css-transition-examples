## Alert CSS

<pre><code class="css" data-trim data-noescape>.alert-wrapper, .alert-details {
    overflow: hidden;
    <mark>transition: height 1000ms;</mark>
    <mark>height: 0px;</mark>
}
</code></pre>

note:
* Here is the associated CSS style for the two wrapper elements that are contained in the alert's
HTML structure
* You can see that <code>transition: height;</code> specification, and that the initial height
value is set to zero pixels.
* We're setting the duration to 1000ms so that it's more apparent. You would probably use something
a little snappier in your application, like 600ms.
* We set <code>overflow: hidden;</code> to make the content initially invisible.
