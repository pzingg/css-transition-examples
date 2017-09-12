##  Starting the animation in the `Alert.update` function

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
* Here's the code that handles that <code>Resized</code> message in our <code>Alert.update</code> function.
* We use a helper function (not shown) named <code>resized</code> that will update the properties of our alert model
and change the state from <code>Opening</code> to <code>Summary</code>, so our <code>view</code> function will
then set the target height of the animation and we'll be off and animating.
* There's also a helper function named <code>dissmissalCmd</code> that will send off a delayed message to close
the alert if we specified that the alert should be dismissed on a timeout.
* And we also return an "OutMsg" to our caller in case she is interested in the start of the animation.
