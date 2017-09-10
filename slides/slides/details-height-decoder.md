## Decoding the details element's height

```elm
detailsHeightDecoder : Json.Decode.Decoder Float
detailsHeightDecoder =
    Json.Decode.at
        [ "target"
        , "firstChild"
        , "lastChild"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.Decode.float
```

note:
    Here's another decoder to get the offsetHeight of the details element from the same alertSizes event.
    It has to walk through three descendant elements.
