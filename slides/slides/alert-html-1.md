## Alert widget HTML structure

<pre><code class="elm" data-trim data-noescape>div [ class "alert-wrapper row", id "alert-info", ... ]

    [ div [ class "content alert-info alert-dismissable ...", ... ]
        [ button [ ... ] [ span [ ... ] [ text "×" ] ]
        , text "Summary content goes here."
        , button [ ... ] [ text "details" ]

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
* Here is a simplified view of the DOM tree structure for our alert, as emitted in our Elm view function.
* Bootstrap provides a lot of the basic CSS styles for the content areas.
