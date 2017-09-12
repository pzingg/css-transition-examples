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
* We'll need to write another Json decoder to get the <code>offsetHeight</code> of the details element from the same "alertSizes" event.
* It has to walk through three descendant elements before getting the <code>offsetHeight</code> value.
