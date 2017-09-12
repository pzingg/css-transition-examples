##  Sending the `Resized` message

<pre><code class="elm" data-trim data-noescape>resizeHandler : String -> Dismissal -> Json.Decode.Decoder Msg
resizeHandler domId dismissal =
    <mark>Json.Decode.map2 (,) wrapperHeightDecoder detailsHeightDecoder</mark>
        <mark>|> Json.Decode.andThen</mark>
            (\( summaryHeight, detailsHeight ) ->
                Resized domId dismissal summaryHeight detailsHeight
                    |> Json.Decode.succeed
            )
</code></pre>

note:
* Now that we have the two height decoders, we can hook them to the "alertSizes" handler in our view.
* First, we use <code>Json.Decode.map2</code> and <code>Json.Decode.andThen</code> to combine the results of the decoders.
