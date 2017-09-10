##  Maintaining the Alert's state

```elm
type Visibility
    = Hidden
    | Opening
    | Summary
    | Details
    | SummaryClosing
    | DetailsClosing
```

and

```elm
type alias Properties =
    { instanceId : Int
    , dismissal : Dismissal
    , visibility : Visibility
    , summaryHeight : Float
    , detailsHeight : Float
    }
```

note:
    Put your speaker notes here.
    You can see them pressing 's'.
