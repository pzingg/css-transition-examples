##  Maintaining the Alert's state

<pre class="fragment"><code class="elm">type Visibility
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
    Put your speaker notes here.
    You can see them pressing 's'.
