##  Elm `view` helper

<pre class="fragment"><code class="elm" data-trim data-noescape>summaryStyles : Properties -> List ( String, String )
summaryStyles { visibility, summaryHt, detailsHt } =
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
</code></pre>

note:
* Now that we have the heights we need, we can use a few helper functions to set the initial and target values for our
animations.
* Depending on the visibility state, we'll set the height value for the outermost wrapper as either zero,
the height of just the summary content (with padding), or the combined height of the summary and details contents.
* Here's an example.
