##  The `Alert.view` function

Handling the alertSizes and transitionend events

```elm
view : Config -> State -> Html Msg
view ({ domId, dismissal } as config) state =
    div
        [ id domId
        , class alertWrapperClass
        , style <| wrapperStylesFor <| getProperties domId state
        , on "alertSizes" <| resizeHandler domId dismissal
        , onWithOptions "transitionend"
            { stopPropagation = True, preventDefault = True }
            (TransitionEnd domId domId |> Json.Decode.succeed)
        ]
        [ viewContent config state ]

```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
