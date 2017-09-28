## Attaching event handlers <br>in the `Alert.view` function

<pre><code class="elm" data-trim data-noescape>view : Config -> State -> Html Msg
view ({ domId } as config) state =
    div
        [ id domId, class "alert-wrapper", style [ ... ]

        , on "alertSizes"</mark>
             <mark><| resizeHandler domId</mark>

        , on "transitionend"</mark>
             <mark><| Json.Decode.succeed <| TransitionEnd domId domId</mark>
        ]
        [ viewContent config state ]

</code></pre>

note:
* The "alertSizes" handler we've seen before; it will send the `Resized` message
* The "transitionend" handler just sends a `TransitionEnd` message
