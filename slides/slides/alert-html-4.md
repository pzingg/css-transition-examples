## Alert widget HTML structure

<pre><code class="elm" data-trim data-noescape>div [ class "alert-wrapper row", id "alert-info", ... ]

    [ div [ class "content alert-info alert-dismissable ...", ... ]
        [ button [ ... ] [ span [ ... ] [ text "×" ] ]
        , text "Summary content goes here."
        , button [ ... ] [ text "details" ]
        
        , div [ class "alert-details", id "alert-info-details", ... ]

            <mark>[ div [ class "content" ]</mark>
                <mark>[ div [] [ label [] [ text "details:" ] ]</mark>
                <mark>, text "Expanded details content goes here."</mark>
                <mark>]</mark>
            <mark>]</mark>
        ]
    ]
</code></pre>

note:
* ...and a nested details-level content area.
* Each of these two content areas can be specified by the programmer, so we must be able to find
out what the target heights of these areas will be, to animate them.
