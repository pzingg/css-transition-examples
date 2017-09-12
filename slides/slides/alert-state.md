##  Maintaining the Alert's state

<pre><code class="elm">type Visibility
    = Hidden
    | Opening
    | Summary
    | Details
    | SummaryClosing
    | DetailsClosing
</code></pre>

<div class="fragment">
The full set of properties:

<pre><code class="elm">type alias Properties =
    { instanceId : Int
    , dismissal : Dismissal
    , visibility : Visibility
    , summaryHeight : Float
    , detailsHeight : Float
    }
</code></pre>
</div>

note:
* Here you can see our visibility type with tags representing the different possible visibilities
for the widget
* And here is the type alias for the full set of properties we need to maintain
for each alert widget. It includes a few other values that must be set and read dynamically.
* Specifically we will be obtaining the (initially hidden) height of the content areas
we will be animating, so we keep them in the properties record.
