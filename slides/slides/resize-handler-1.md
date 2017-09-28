## Sending height values<br>in a `Resized` message

<pre><code class="elm" data-trim data-noescape>resizeHandler : String -> Json.Decode.Decoder Msg
resizeHandler domId =
    <mark>Json.Decode.map2 (,) summaryHeightDecoder detailsHeightDecoder</mark>
        <mark>|> Json.Decode.andThen</mark>

            (\( summaryHeight, detailsHeight ) ->
                Json.Decode.succeed
                    <| Resized domId summaryHeight detailsHeight
            )
</code></pre>

note:
* Now that we have the two height decoders, we can hook them to the "alertSizes" handler in our view.
* First, we use `Json.Decode.map2` and `Json.Decode.andThen` to combine the results of the decoders.
