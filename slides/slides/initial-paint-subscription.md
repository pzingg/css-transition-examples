##  Sending the `InitialPainted` message with a Sub

```elm
subscriptions : State -> Sub Msg
subscriptions (State priv) =
    let
        initialPaintFilter _ props =
            props.visibility == InitialPaint
    in
        case Dict.filter initialPaintFilter priv.bag |> Dict.isEmpty of
            False ->
                AnimationFrame.times InitialPainted

            True ->
                Sub.none
```

note:
* Here's the subscription code that we could have used for the alert example
* If we are waiting for the view to be painted on any of our alerts, we set up a subscription
that will send us an <code>InitialPainted</code> message using the <code>AnimationFrame.times</code> function.
