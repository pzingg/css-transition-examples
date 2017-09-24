##  `subscriptions` for update/view timing

<pre><code class="elm" data-trim data-noescape>subscriptions : State -> Sub Msg
subscriptions (State priv) =
    let
        initialRenderFilter _ props =
            -- filter alerts that need an initial state rendering
            props.visibility == InitialRender
    in
        case Dict.filter initialRenderFilter priv.bag |> Dict.isEmpty of
            False ->
                -- if we have any, send an InitialRendered message
                -- on the next animation frame tick
                <mark>AnimationFrame.times InitialRendered</mark>

            True ->
                Sub.none
</code></pre>

note:
* Here's the subscription code that we could have used for the alert example
* If we are waiting for the view to be rendered on any of our alerts, we set up a subscription
that will send us an `InitialRendered` message using the `AnimationFrame.times` function.
