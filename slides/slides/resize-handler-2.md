## Sending height values<br>in a `Resized` message

<pre><code class="elm" data-trim data-noescape>resizeHandler : String -> Json.Decode.Decoder Msg
resizeHandler domId =
    Json.Decode.map2 (,) summaryHeightDecoder detailsHeightDecoder
        |> Json.Decode.andThen

            (\( summaryHeight, detailsHeight ) ->
                <mark>Json.Decode.succeed</mark>
                    <mark><| Resized domId summaryHeight detailsHeight</mark>
            )
</code></pre>

note:
* Then, we package the height values and a few other parameters that we'll need, into a `Resized` Elm message
