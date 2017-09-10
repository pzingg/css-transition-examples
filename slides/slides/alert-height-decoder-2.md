## Decoding the details element's height

Another decoder for the details element

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
    Put your speaker notes here.
    You can see them pressing 's'.
