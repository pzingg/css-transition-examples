##  Handling the `InitialRendered` message

<pre><code class="elm" data-trim data-noescape>initialRendered : State -> ( State, Cmd Msg )
initialRendered (State priv) =
    let
        accumulator domId props ( bag, xsCmds ) =
            case props.visibility of
                InitialRender ->
                    <mark>( Dict.insert</mark>
                        <mark>domId { props | visibility = Opening } bag</mark>
                    <mark>, (openAlertImmediate domId) :: xsCmds )</mark>

                _ ->
                    ( Dict.insert domId props bag, xsCmds )

        ( nextBag, cmdList ) =
            Dict.foldl accumulator ( Dict.empty, [] ) priv.bag
    in
        ( State { priv | bag = nextBag }, Cmd.batch cmdList )
</code></pre>

note:
* And here's where we handle that `InitialRendered` message/
* We add a JavaScript port call, `openAlertImmediate`, for any of the alerts that are in the
`InitialRender` visibility state.
* And now `openAlertImmediate` doesn't have to wait for an animation frame, because we know
these alerts have been rendered on the VDOM already.
