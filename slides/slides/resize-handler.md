##  Sending the `Resized` message

<pre><code class="elm" data-trim data-noescape>resizeHandler : String -> Dismissal -> Json.Decode.Decoder Msg
resizeHandler domId dismissal =
    Json.Decode.map2 (,) wrapperHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( summaryHeight, detailsHeight ) ->
                <mark>Resized domId dismissal summaryHeight detailsHeight</mark>
                    <mark>|> Json.Decode.succeed</mark>
            )
</code></pre>

note:
    Now that we have the two decoders we can use Json.Decode.map2 to combine the results of decoding the
    alertSizes DOM event, and then package the height values into a `Resized` Elm message
