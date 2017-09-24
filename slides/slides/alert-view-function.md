## Using the updated properties<br>in the `Alert.view` function

<pre><code class="elm" data-trim data-noescape>view : Config -> State -> Html Msg
view ({ domId, dismissal } as config) state =
    div
        [ id domId, class alertWrapperClass

        <mark>-- summaryStyles returns a List, like [ ( "height", "82px" ) ]</mark>
        <mark>, style <| summaryStyles <| getProperties domId state</mark>

        <mark>-- handlers for the alertSizes and transitioned events</mark>
        <mark>, on "alertSizes"</mark>
             <mark><| resizeHandler domId dismissal</mark>

        <mark>, on "transitionend"</mark>
             <mark><| Json.Decode.succeed <| TransitionEnd domId domId</mark>
        ]
        [ viewContent config state ]

</code></pre>

note:
* And here is the top of the `Alert.view` function.
* You'll see where the outermost wrapper element has the "alertSizes" and "transtionend" event handlers
* The "alertSizes" handler we've seen before; it will send the `Resized` message
* The "transitionend" handler just sends a `TransitionEnd` message
* And you can see where the `style` of the wrapper, like `height: 0px`, comes from
a `summaryStyles` helper function, that we'll look at next.
