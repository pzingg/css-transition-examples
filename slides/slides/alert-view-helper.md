## Using the updated model<br>in the `Alert.view` function

<pre class="fragment"><code class="elm" data-trim data-noescape>summaryStyles : Properties -> List ( String, String )
summaryStyles { visibility, summaryHt, detailsHt } =
    case visibility of
        -- These states add 10px or 20px to account for element padding
        <mark>Summary -></mark>
            <mark>[ ( "height"</mark>
              <mark>, toString (summaryHt + 10) ++ "px" ) ]</mark>

        Details ->
            [ ( "height"
              , toString (summaryHt + detailsHt + 20) ++ "px" ) ]

        -- This state sets the computed value to zero to close the alert
        SummaryClosing ->
            [ ( "height", "0px" ) ]

        ...
</code></pre>

note:
* Now that we have the heights we need, we can use a helper function to set the target values
to kick off the transition.
* We will generate a list of properties for the `style` Attribute with this function.
* Depending on the visibility state, we'll set the height value for the outermost wrapper as either zero,
the height of just the summary content (with padding), or the combined height of the summary
and details contents.
