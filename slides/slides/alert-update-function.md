##  The `Alert.update` function

```elm
update : Msg -> State -> ( State, Cmd Msg, Maybe OutMsg )
update msg state =
    case msg of
        Resized domId dismissal summaryHeight detailsHeight ->
            let
                ( nextState, props ) =
                    resized domId summaryHeight detailsHeight state
            in
                ( nextState
                , dismissalCmd domId dismissal state
                , Just <| TransitionStarted domId props.visibility
                )
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
