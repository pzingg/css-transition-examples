module Alert
    exposing
        ( Severity(..)
        , Dismissal(..)
        , Config
        , State
        , init
        , close
        , detailsClicked
        , view
        )

{-| This library fills a bunch of important niches in Elm. A `Maybe` can help
you with optional arguments, error handling, and records with optional fields.

Implemetation lifted from rundis/elm-bootstrap package (Accordion module),
which in turn uses debois/elm-dom library.

See https://github.com/debois/elm-dom/tree/master for rationale.

# Definition
@docs Maybe

# Common Helpers
@docs map, withDefault, oneOf

# Chaining Maybes
@docs andThen

-}

import Dict exposing (Dict)
import Html exposing (Html, node, text, div, span, label, button)
import Html.Attributes exposing (attribute, id, class, type_, style)
import Html.Events exposing (onClick, onWithOptions)


-- TYPES


type Severity
    = Error
    | Info
    | Success


type Dismissal
    = DismissAfter Float
    | DismissOnPageChange
    | DismissOnUserAction


type alias Config msg =
    { domId : String
    , severity : Severity
    , dismssal : Dismissal
    , summary : String
    , details : Maybe String
    , closeTagger : String -> State -> msg
    , detailsTagger : Maybe (String -> State -> msg)
    }


type Visibility
    = Hidden
    | Summary
    | Details
    | Closing


type alias Properties =
    { visibility : Visibility
    , summaryHeight : Maybe Float
    , detailsHeight : Maybe Float
    }


type State
    = State (Dict String Properties)



-- INIT


init : State
init =
    State Dict.empty



-- UPDATE


getAlertState : String -> State -> Properties
getAlertState domId (State alertProps) =
    Dict.get domId alertProps
        |> Maybe.withDefault
            { visibility = Hidden
            , summaryHeight = Nothing
            , detailsHeight = Nothing
            }


mapProperties : String -> (Properties -> Properties) -> State -> State
mapProperties domId mapperFn ((State alertProps) as state) =
    let
        updateProperties =
            getAlertState domId state
                |> mapperFn
    in
        State (Dict.insert domId updateProperties alertProps)


close : String -> State -> State
close domId state =
    mapProperties domId
        (\props -> { props | summaryHeight = Just 0 } )
        state


detailsClicked : String -> State -> State
detailsClicked domId state =
    state



-- VIEW


view : Config msg -> State -> Html msg
view config state =
    div
        [ id config.domId
        , class alertWrapperClass
        ]
        [ viewContent config state ]


emptyHtml : Html msg
emptyHtml =
    text ""


detailsButton : String -> Maybe (String -> State -> msg) -> State -> Html msg
detailsButton domId detailsTagger state =
    case detailsTagger of
        Nothing ->
            emptyHtml

        Just tagger ->
            button
                [ class smallLinkButtonClass, onClick (tagger domId state) ]
                [ text "details" ]


detailsContent : String -> Maybe String -> Html msg
detailsContent domId details =
    case details of
        Nothing ->
            emptyHtml

        Just str ->
            div [ id (domId ++ "-details"), class "alert-details" ]
                [ div [ class "content" ]
                    [ div []
                        [ label [] [ text "details:" ] ]
                    , text str
                    ]
                ]


viewContent : Config msg -> State -> Html msg
viewContent { domId, severity, dismssal, summary, details, closeTagger, detailsTagger } state =
    if String.isEmpty summary then
        emptyHtml
    else
        div
            [ class (getContentClassNames severity ++ " content")
            , attribute "role" "alert"
            ]
            [ button
                [ attribute "role" "button"
                , type_ "button"
                , class "close"
                , attribute "data-dismiss" "alert"
                , attribute "aria-label" "Close"
                , onClick (closeTagger domId state)
                ]
                [ span
                    [ attribute "aria-hidden" "true" ]
                    -- unicode U+00D7 or &times;
                    [ text "×" ]
                ]
            , text summary
            , detailsButton domId detailsTagger state
            , detailsContent domId details
            ]


getContentClassNames : Severity -> String
getContentClassNames severity =
    case severity of
        Error ->
            alertErrorClass

        Info ->
            alertInfoClass

        Success ->
            alertSuccessClass


smallLinkButtonClass : String
smallLinkButtonClass =
    "btn btn-link btn-sm"


alertWrapperClass : String
alertWrapperClass =
    "alert-wrapper row"


alertErrorClass : String
alertErrorClass =
    "alert alert-danger alert-dismissable error col-xs-12"


alertInfoClass : String
alertInfoClass =
    "alert alert-info alert-dismissable info col-xs-12"


alertSuccessClass : String
alertSuccessClass =
    "alert alert-success alert-dismissable col-xs-12"
