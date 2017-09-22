##  Starting the animation in the `Alert.update` function

```elm
update : Msg -> State -> ( State, Cmd Msg, Maybe OutMsg )
update msg state =
    case msg of
        Resized domId dismissal summaryHeight detailsHeight ->
            let
                ( nextState, props ) =
                    -- resized changes visibility from Opening to Summary
                    resized domId summaryHeight detailsHeight state

                cmd =
                    -- dismissalCmd sends a close message in the future
                    dismissalCmd domId dismissal state

                outMsg =
                    -- an OutMsg for application to use
                    Just <| TransitionStarted domId props.visibility
            in
                ( nextState, cmd, outMsg )
```

note:
* Here's the code that handles that `Resized` message in our `Alert.update` function.
* We use a helper function `resized` that will update the properties of our alert model
and change the state from `Opening` to `Summary`, so our `view` function will
then set the target height of the animation and we'll be off and animating.
* There's also a helper function named `dissmissalCmd` that will send off a delayed message to close
the alert if we specified that the alert should be dismissed on a timeout.
* And we also return an `OutMsg` to our caller in case she is interested in the start of the animation.
