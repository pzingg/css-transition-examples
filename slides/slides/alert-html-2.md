## Alert widget HTML structure

<pre><code class="elm" data-trim data-noescape>div [ class "alert-wrapper row", id "alert-info", ... ]

    <mark>[ div [ class "content alert-info alert-dismissable ...", ... ]</mark>
        <mark>[ button [ ... ] [ span [ ... ] [ text "×" ] ]</mark>
        <mark>, text "Summary content goes here."</mark>
        <mark>, button [ ... ] [ text "details" ]</mark>
        <mark>, div [ class "alert-details", id "alert-info-details", ... ]</mark>

            [ div [ class "content" ]
                [ div [] [ label [] [ text "details:" ] ]
                , text "Expanded details content goes here."
                ]
            ]
        ]
    ]
</code></pre>

note:
* You can see that there are two divs with a "content" class, and "wrapper" divs around them.
* There is a summary-level content area...
