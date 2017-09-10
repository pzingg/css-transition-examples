##  Elm `view` helper

```elm
wrapperStylesFor : Properties -> List ( String, String )
wrapperStylesFor { visibility, summaryHeight, detailsHeight } =
    case visibility of
        Summary ->
            [ ( "height"
              , toString (summaryHeight + 10) ++ "px" ) ]

        Details ->
            [ ( "height"
              , toString (summaryHeight + detailsHeight + 20) ++ "px" ) ]

        SummaryClosing ->
            [ ( "height", "0px" ) ]

        DetailsClosing ->
            [ ( "height", "0px" ) ]

        _ ->
            []
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
