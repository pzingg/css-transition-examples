##  Handling the `InitialPainted` message

```elm
initialPainted : State -> ( State, Cmd Msg )
initialPainted (State priv) =
    let
        initialPaintAccumulator domId props ( dictProps, xsCmds ) =
            case props.visibility of
                InitialPaint ->
                    ( Dict.insert domId { props | visibility = Opening } dictProps
                    , (openAlertImmediate domId) :: xsCmds
                    )

                _ ->
                    ( Dict.insert domId props dictProps, xsCmds )

        ( nextBag, cmdList ) =
            Dict.foldl initialPaintAccumulator ( Dict.empty, [] ) priv.bag
    in
        ( State { priv | bag = nextBag }, Cmd.batch cmdList )
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
