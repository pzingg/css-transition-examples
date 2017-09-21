## Alert CSS

<pre><code class="css" data-trim data-noescape>.alert-wrapper, .alert-details {
    overflow: hidden;
    transition: height 1000ms;
    height: 0px;
}

.alert-details.open .content {
    margin: 5px 0;
    padding: 5px 0;
    border-top: 1px #a94442 solid;
}
</code></pre>

note:
* And here is the associated CSS styles for that structure.
