##  Elm `view` helper

```elm
wrapperStylesFor : Properties -> List ( String, String )
wrapperStylesFor { visibility, summaryHt, detailsHt } =
    case visibility of
        Summary ->
            [ ( "height"
              , toString (summaryHt + 10) ++ "px" ) ]

        Details ->
            [ ( "height"
              , toString (summaryHt + detailsHt + 20) ++ "px" ) ]

        SummaryClosing ->
            [ ( "height", "0px" ) ]

        ...
        _ ->
            []
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
