##  Sending the `Resized` message

Map the two decoders to convert the alertSizes DOM event
into a `Resized` Elm message

```elm
resizeHandler : String -> Dismissal -> Json.Decode.Decoder Msg
resizeHandler domId dismissal =
    Json.map2 (,) wrapperHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( summaryHeight, detailsHeight ) ->
                Resized domId dismissal summaryHeight detailsHeight
                    |> Json.Decode.succeed
            )
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
