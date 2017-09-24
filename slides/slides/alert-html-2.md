## Alert widget HTML structure

<pre><code class="elm" data-trim data-noescape><mark>div [ class "alert-wrapper row", id "alert-info", ... ]</mark>

    [ div [ class "content alert-info alert-dismissable ...", ... ]
        [ button [ ... ] [ span [ ... ] [ text "×" ] ]
        , text "Summary content goes here."
        , button [ ... ] [ text "details" ]

        , <mark>div [ class "alert-details", id "alert-info-details", ... ]</mark>

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
