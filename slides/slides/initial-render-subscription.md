##  Sending the `InitialRendered` message with a Sub

<pre><code class="elm" data-trim data-noescape>subscriptions : State -> Sub Msg
subscriptions (State priv) =
    let
        -- If alert is waiting for a VDOM render for initial state
        initialRenderFilter _ props =
            props.visibility == InitialRender
    in
        case Dict.filter initialRenderFilter priv.bag |> Dict.isEmpty of
            False ->
                <mark>AnimationFrame.times InitialRendered</mark>

            True ->
                Sub.none
</code></pre>

note:
* Here's the subscription code that we could have used for the alert example
* If we are waiting for the view to be rendered on any of our alerts, we set up a subscription
that will send us an `InitialRendered` message using the `AnimationFrame.times` function.
