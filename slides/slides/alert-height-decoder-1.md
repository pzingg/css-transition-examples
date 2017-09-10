##  Decoding the summary element's height

Use the HTML structure to walk down to the summary content element

```elm
wrapperHeightDecoder : Json.Decode.Decoder Float
wrapperHeightDecoder =
    Json.Decode.at
        [ "target"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.Decode.float
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
