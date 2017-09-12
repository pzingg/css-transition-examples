##  The `Alert.view` function

<pre><code class="elm" data-trim data-noescape>view : Config -> State -> Html Msg
view ({ domId, dismissal } as config) state =
    div
        [ id domId
        , class alertWrapperClass
        <mark>, style <| wrapperStylesFor <| getProperties domId state</mark>
        <mark>, on "alertSizes" <| resizeHandler domId dismissal</mark>
        <mark>, onWithOptions "transitionend"</mark>
            <mark>{ stopPropagation = True, preventDefault = True }</mark>
            <mark>(TransitionEnd domId domId |> Json.Decode.succeed)</mark>
        ]
        [ viewContent config state ]

</code></pre>

note:
* And here is the top of the <code>Alert.view</code> function.
* You'll see where the outermost wrapper element has the "alertSizes" and "transtionend" event handlers
* The "alertSizes" handler we've seen before; it will send the <code>Resized</code> message
* The "transitionend" handler just sends a <code>TransitionEnd</code> message
* And you can see where the <code>style</code> of the wrapper, like <code>height: 0px</code>, comes from
the <code>wrapperStylesFor</code> helper function from the last slide.
