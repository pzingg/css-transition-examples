##  Handling the `InitialPainted` message

<pre><code class="elm" data-trim data-noescape>initialPainted : State -> ( State, Cmd Msg )
initialPainted (State priv) =
    let
        openAlerts domId props ( bag, xsCmds ) =
            case props.visibility of
                InitialPaint ->
                    ( Dict.insert domId
                        { props | visibility = Opening } bag
                    , (<mark>openAlertImmediate domId</mark>) :: xsCmds
                    )

                _ ->
                    ( Dict.insert domId props bag, xsCmds )

        ( nextBag, cmdList ) =
            Dict.foldl openAlerts ( Dict.empty, [] ) priv.bag
    in
        ( State { priv | bag = nextBag }, Cmd.batch cmdList )
</code></pre>

note:
* And here's where we handle that <code>InitialPainted</code> message/
* We add a JavaScript port call, <code>openAlertImmediate</code>, for any of the alerts that are in the
<code>InitialPaint</code> visibility state.
* And now <code>openAlertImmediate</code> doesn't have to wait for an animation frame, because we know
these alerts have been painted on the VDOM already.
