##  Decoding the summary element's height


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

<div class="fragment">Almost like JavaScript!</div>

note:
    Use the HTML structure to walk from the target of the alertSizes event
        down to the summary content element, and then get it's offsetHeight as a float value.
