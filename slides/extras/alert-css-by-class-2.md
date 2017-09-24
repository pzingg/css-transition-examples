## Using DOM class to set target

...and then in Elm, we change those class names dynamically:

<pre><code class="elm" data-trim data-noescape>div [ <mark>class <| carouselItemClasses route model</mark>
    , ...
    ]
    [ div [ class "row" ]
        [ div [ class "col-lg-12" ] content ]
    ]
</code></pre>
</div>

note:
* The `carouselItemClasses` helper function sets the class names based on the
animation state of the model.
