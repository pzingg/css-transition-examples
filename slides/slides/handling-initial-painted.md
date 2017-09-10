##  Handling the `InitialPainted` message

```elm
initialPainted : State -> ( State, Cmd Msg )
initialPainted (State priv) =
    let
        openAlerts domId props ( bag, xsCmds ) =
            case props.visibility of
                InitialPaint ->
                    ( Dict.insert domId
                        { props | visibility = Opening } bag
                    , (openAlertImmediate domId) :: xsCmds
                    )

                _ ->
                    ( Dict.insert domId props bag, xsCmds )

        ( nextBag, cmdList ) =
            Dict.foldl openAlerts ( Dict.empty, [] ) priv.bag
    in
        ( State { priv | bag = nextBag }, Cmd.batch cmdList )
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
