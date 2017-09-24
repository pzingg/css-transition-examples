## Sending height values<br>in a `Resized` message

<pre><code class="elm" data-trim data-noescape>resizeHandler : String -> Dismissal -> Json.Decode.Decoder Msg
resizeHandler domId dismissal =
    Json.Decode.map2 (,) summaryHeightDecoder detailsHeightDecoder
        |> Json.Decode.andThen

            (\( summaryHeight, detailsHeight ) ->
                <mark>Json.Decode.succeed</mark>
                    <mark><| Resized domId dismissal summaryHeight detailsHeight</mark>
            )
</code></pre>

note:
* Then, we package the height values and a few other parameters that we'll need, into a `Resized` Elm message
