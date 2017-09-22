##  Decoding element heights

<pre class="fragment"><code class="elm" data-trim data-noescape>summaryHeightDecoder : Json.Decode.Decoder Float
summaryHeightDecoder =
    Json.Decode.at
        [ "target"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.Decode.float
</code></pre>

<pre class="fragment"><code class="elm" data-trim data-noescape>detailsHeightDecoder : Json.Decode.Decoder Float
detailsHeightDecoder =
    Json.Decode.at
        [ "target"
        , "firstChild"
        , "lastChild"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.Decode.float
</code></pre>

<div class="fragment">Almost like writing JavaScript, but type-safe in Elm!</div>

note:
* So that's all the JavaScript we'll need. Now let's handle that "alertSizes" event with a JSON decoder in Elm. Here's the code.
* Knowing that the "target" of the event was the outermost wrapper element, we use the HTML structure to walk from the target
down to the summary content element (its first child), and then obtain the `offsetHeight` of the content as a float value.
* An alternative to using `Json.Decode.at` is to use Søren Debois's elm-dom package which does the same thing
in a pipeline-flavored way.

References:
* [DOM traversal for Elm event-handlers](https://github.com/debois/elm-dom)
