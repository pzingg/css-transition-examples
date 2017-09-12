##  Decoding the summary element's height

<pre class="fragment"><code class="elm" data-trim data-noescape>summaryHeightDecoder : Json.Decode.Decoder Float
summaryHeightDecoder =
    Json.Decode.at
        [ "target"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.Decode.float
</code></pre>

<div class="fragment">Almost like JavaScript, but type-safe in Elm!</div>

note:
* So that's all the JavaScript we'll need. Now let's handle that "alertSizes" event with a Json decoder in Elm. Here's the code.
* Knowing that the "target" of the event was the outermost wrapper element, we use the HTML structure to walk from the target
down to the summary content element (it's first child), and then obtain the <code>offsetHeight</code> of the content as a float value.
* An alternative to using <code>Json.Decode.at</code> is to use Søren Debois's elm-dom package which does the same thing
in a pipeline-flavored way.

References:
* [DOM traversal for Elm event-handlers](https://github.com/debois/elm-dom)
