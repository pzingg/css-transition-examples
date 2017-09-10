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
    For alerts in the InitalPaint visibility state, AnimationFrame.times Sub will send an InitialPainted message
        on each cycle
