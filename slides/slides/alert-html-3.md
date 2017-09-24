## Alert widget HTML structure

<pre><code class="elm" data-trim data-noescape>div [ class "alert-wrapper row", id "alert-info", ... ]

    <mark>[ div [ class "content alert-info alert-dismissable ...", ... ]</mark>
        <mark>[ button [ ... ] [ span [ ... ] [ text "×" ] ]</mark>
        <mark>, text "Summary content goes here."</mark>
        <mark>, button [ ... ] [ text "details" ]</mark>

        , div [ class "alert-details", id "alert-info-details", ... ]

            [ div [ class "content" ]
                [ div [] [ label [] [ text "details:" ] ]
                , text "Expanded details content goes here."
                ]
            ]
        ]
    ]
</code></pre>

note:
* ...and a nested details-level content area.
* Each of these two content areas can be specified by the programmer, so we must be able to find
out what the target heights of these areas will be, to animate them.
