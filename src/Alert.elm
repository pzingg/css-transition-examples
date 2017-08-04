module Alert
    exposing
        ( Severity(..)
        , Dismissal(..)
        , Config
        , State
        , init
        , open
        , opened
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
import DOM
import Html exposing (Html, node, text, div, span, label, button)
import Html.Attributes exposing (attribute, id, class, classList, type_, style)
import Html.Events exposing (onClick, on)
import Json.Decode as Json exposing (Decoder, field)
import Ports exposing (openAlert)


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
    , openTagger : String -> Float -> Float -> State -> msg
    , closeTagger : String -> State -> msg
    , detailsTagger : Maybe (String -> State -> msg)
    }


type Visibility
    = Hidden
    | Opening
    | Summary
    | Details
    | SummaryClosing
    | DetailsClosing


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


open : String -> State -> ( State, Cmd msg )
open domId state =
    ( mapProperties domId
        (\props ->
            { props
                | visibility = Opening
                , summaryHeight = Nothing
                , detailsHeight = Nothing
            }
        )
        state
    , openAlert domId
    )


opened : String -> Float -> Float -> State -> State
opened domId sHeight dHeight state =
    mapProperties domId
        (\props ->
            { props
                | visibility = Summary
                , summaryHeight = Just sHeight
                , detailsHeight = Just dHeight
            }
        )
        state


close : String -> State -> State
close domId state =
    mapProperties domId
        (\props -> case props.visibility of
            Details ->
                { props | visibility = DetailsClosing }

            Summary ->
                { props | visibility = SummaryClosing }

            _ ->
                props
        )
        state


detailsClicked : String -> State -> State
detailsClicked domId state =
    mapProperties domId
        (\props ->
            case props.visibility of
                Summary ->
                    { props | visibility = Details }

                Details ->
                    { props | visibility = Summary }

                _ ->
                    props
        )
        state


mapProperties : String -> (Properties -> Properties) -> State -> State
mapProperties domId mapperFn ((State alertProps) as state) =
    let
        updateProperties =
            getAlertProperties domId state
                |> mapperFn
    in
        State (Dict.insert domId updateProperties alertProps)


getAlertProperties : String -> State -> Properties
getAlertProperties domId (State state) =
    Dict.get domId state
        |> Maybe.withDefault
            { visibility = Hidden
            , summaryHeight = Nothing
            , detailsHeight = Nothing
            }



-- VIEW


view : Config msg -> State -> Html msg
view config state =
    let
        decoder =
            openHandler config.domId state config.openTagger

        props =
            getAlertProperties config.domId state

        styles =
            Debug.log "wrapperStyles" <| wrapperStylesFor props
    in
        div
            [ id config.domId
            , class alertWrapperClass
            , style styles
            , on "alertOpen" decoder
            ]
            [ viewContent config state ]


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
            , detailsContent domId details state
            ]


detailsButton : String -> Maybe (String -> State -> msg) -> State -> Html msg
detailsButton domId detailsTagger state =
    case detailsTagger of
        Nothing ->
            emptyHtml

        Just tagger ->
            button
                [ class smallLinkButtonClass, onClick (tagger domId state) ]
                [ text "details" ]


detailsContent : String -> Maybe String -> State -> Html msg
detailsContent domId details state =
    case details of
        Nothing ->
            emptyHtml

        Just str ->
            let
                props =
                    getAlertProperties domId state

                styles =
                    Debug.log "detailsStyles" <| detailsStylesFor props
            in
                div
                    [ id (domId ++ "-details")
                    , classList
                        [ ( "alert-details", True )
                        , ( "open", detailsOpenFor props )
                        ]
                    , style styles
                    ]
                    [ div [ class "content" ]
                        [ div []
                            [ label [] [ text "details:" ] ]
                        , text str
                        ]
                    ]


wrapperStylesFor : Properties -> List ( String, String )
wrapperStylesFor { visibility, summaryHeight, detailsHeight } =
    case visibility of
        Summary ->
            let
                sHeight =
                    summaryHeight |> Maybe.withDefault 0
            in
                [ ( "height", toString (sHeight + 10) ++ "px" ) ]

        Details ->
            let
                sHeight =
                    summaryHeight |> Maybe.withDefault 0

                dHeight =
                    detailsHeight |> Maybe.withDefault 0
            in
                [ ( "height", toString (sHeight + dHeight + 20) ++ "px" ) ]

        SummaryClosing ->
            [ ( "height", "0px" ) ]

        DetailsClosing ->
            [ ( "height", "0px" ) ]

        _ ->
            []


detailsOpenFor : Properties -> Bool
detailsOpenFor { visibility } =
    case visibility of
        Details ->
            True

        DetailsClosing ->
            True

        _ ->
            False


detailsStylesFor : Properties -> List ( String, String )
detailsStylesFor { visibility, detailsHeight } =
    case visibility of
        Details ->
            let
                dHeight =
                    detailsHeight |> Maybe.withDefault 0
            in
                [ ( "height", toString (dHeight + 10) ++ "px" ) ]

        _ ->
            [ ( "height", "0px" ) ]


emptyHtml : Html msg
emptyHtml =
    text ""


{-| Get the lastChild of an element.
-}
lastChild : Decoder a -> Decoder a
lastChild decoder =
    field "lastChild" decoder


{-|
<div id="alert-info" class="alert-wrapper" style="height: 0px;">
    <div class="alert alert-danger alert-dismissable error col-xs-12 content" role="alert">
        <button role="button" data-dismiss="alert" aria-label="Close" type="button" class="close">
            <span aria-hidden="true">×</span>
        </button>
        Invalid definition or meta-parameters (invalid parameter values).
        <button class="btn btn-link btn-sm">details</button>
        <div id="alert-info-details" class="alert-details" style="height: 0px;" class="">
            <div class="content">
                <div><label>details:</label></div>
                Only 1 valid value(s) for parameter Quench (at least 2 are required).
            </div>
        </div>
    </div>
</div>

-}
wrapperHeightDecoder : Decoder Float
wrapperHeightDecoder =
    Json.at [ "target", "firstChild", "offsetHeight" ] Json.float


detailsHeightDecoder : Decoder Float
detailsHeightDecoder =
    Json.at [ "target", "firstChild", "lastChild", "firstChild", "offsetHeight" ] Json.float


openHandler : String -> State -> (String -> Float -> Float -> State -> msg) -> Decoder msg
openHandler domId state tagger =
    Json.map2 (,) wrapperHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( sHeight, dHeight ) ->
                Json.succeed <| tagger domId sHeight dHeight state
            )


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
