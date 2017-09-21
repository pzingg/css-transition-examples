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
* Then, we package the height values and a few other parameters that we'll need, into a `Resized` Elm message
