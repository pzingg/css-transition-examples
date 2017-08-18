port module Alert
    exposing
        ( Severity(..)
        , Dismissal(..)
        , Visibility(..)
        , OutMsg(..)
        , Config
        , State
        , Msg
        , init
        , open
        , update
        , openAlert
        , view
        )

{-| This module encapsulates the behavior of an Elm "Alert" component, based on
the Bootstrap JavaScript/CSS "Alert" component. These "Alert" widgets feature
animated opening and closing and can present two levels of text information to
the user--a summary level with a basic message and a details level that the
user can choose to expand if available.


# Configuration

@docs Severity Dismissal Config


# Initialization

@docs init


# Commands

@docs open


# Update

@docs update


# View

@docs view


# Helpers

@docs getContentClassNames

-}

import Dict exposing (Dict)
import Html exposing (Html, node, text, div, span, label, button)
import Html.Attributes exposing (attribute, id, class, classList, type_, style)
import Html.Events exposing (onClick, on, onWithOptions)
import Json.Decode as Json exposing (Decoder, field)


-- CONFIGURATION TYPES


{-| Configuration union type describing the appearance of the alert
(maps to Bootstrap alert styles).
-}
type Severity
    = Error
    | Info
    | Success


{-| Configuration union type describing when the alert should be dismissed:
after a specified number of seconds, after a page change in an SPA, or
only manually (when a user clicks the close [x] button).
-}
type Dismissal
    = DismissAfter Float
    | DismissOnPageChange
    | DismissOnUserAction


{-| Configuration record for fully specifying an alert.

  - `domId` must be a valid DOM id string, applied to an alert's wrapper element;
    the id string must be unique for each alert used in the parent's model
  - `summary` is the (required) string to be shown at the summary level of the
    alert
  - `details` is the (optional) string to be shown when the user clicks the
    "details" link to expand the alert

-}
type alias Config =
    { domId : String
    , severity : Severity
    , dismssal : Dismissal
    , summary : String
    , details : Maybe String
    }


type Visibility
    = Hidden
    | Opening
    | Summary
    | Details
    | SummaryClosing
    | DetailsClosing


type OutMsg
    = TransitionStarted String Visibility
    | TransitionEnded String Visibility



-- PRIVATE PROPERTY TYPES


type alias Properties =
    { visibility : Visibility
    , summaryHeight : Maybe Float
    , detailsHeight : Maybe Float
    }


{-| Opaque type encapsulating the state of all alerts in the parent's model.
The global state is kept in an Elm Dict keyed on the DOM ids of the alert
wrappers.
-}
type State
    = State (Dict String Properties)



-- INIT


{-| Initialize the state of all alerts in the model with an empty Dict.
-}
init : State
init =
    State Dict.empty



-- COMMANDS


open : String -> State -> ( State, Cmd msg )
open domId state =
    let
        ( _, nextState ) =
            mapProperties domId
                (\props ->
                    { props
                        | visibility = Opening
                        , summaryHeight = Nothing
                        , detailsHeight = Nothing
                    }
                )
                state
    in
        ( nextState, openAlert domId )



-- UPDATE


{-| Opaque type that handles all internal messages.
-}
type Msg
    = Resized String Float Float State
    | DetailsClicked String State
    | CloseClicked String State
    | TransitionEnd String String


{-| Update function. No Cmds are returned.
-}
update : Msg -> State -> ( State, Maybe OutMsg )
update msg state =
    case msg of
        Resized domId sHeight dHeight state ->
            let
                ( props, nextState ) =
                    resized domId sHeight dHeight state
            in
                ( nextState, Just <| TransitionStarted domId props.visibility )

        DetailsClicked domId state ->
            let
                ( props, nextState ) =
                    detailsClicked domId state
            in
                ( nextState, Just <| TransitionStarted domId props.visibility )

        CloseClicked domId state ->
            let
                ( props, nextState ) =
                    closeClicked domId state
            in
                ( nextState, Just <| TransitionStarted domId props.visibility )

        TransitionEnd domId componentId ->
            let
                ( props, nextState ) =
                    transitionEnd domId state
            in
                ( nextState, Just <| TransitionEnded componentId props.visibility )


resized : String -> Float -> Float -> State -> ( Properties, State )
resized domId sHeight dHeight state =
    let
        ( props, nextState ) =
            mapProperties domId
                (\props ->
                    case props.visibility of
                        Opening ->
                            { props
                                | visibility = Summary
                                , summaryHeight = Just sHeight
                                , detailsHeight = Just dHeight
                            }

                        _ ->
                            { props
                                | summaryHeight = Just sHeight
                                , detailsHeight = Just dHeight
                            }
                )
                state
    in
        ( props, nextState )


detailsClicked : String -> State -> ( Properties, State )
detailsClicked domId state =
    let
        ( props, nextState ) =
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
    in
        ( props, nextState )


closeClicked : String -> State -> ( Properties, State )
closeClicked domId state =
    let
        ( props, nextState ) =
            mapProperties domId
                (\props ->
                    case props.visibility of
                        Details ->
                            { props | visibility = DetailsClosing }

                        Summary ->
                            { props | visibility = SummaryClosing }

                        _ ->
                            props
                )
                state
    in
        ( props, nextState )


transitionEnd : String -> State -> ( Properties, State )
transitionEnd domId state =
    let
        ( props, nextState ) =
            mapProperties domId
                (\props ->
                    case props.visibility of
                        DetailsClosing ->
                            { props | visibility = Hidden }

                        SummaryClosing ->
                            { props | visibility = Hidden }

                        _ ->
                            props
                )
                state
    in
        ( props, nextState )


mapProperties : String -> (Properties -> Properties) -> State -> ( Properties, State )
mapProperties domId mapperFn ((State props) as state) =
    let
        nextProperties =
            getProperties domId state
                |> mapperFn
    in
        ( nextProperties, State (Dict.insert domId nextProperties props) )


getProperties : String -> State -> Properties
getProperties domId (State state) =
    Dict.get domId state
        |> Maybe.withDefault
            { visibility = Hidden
            , summaryHeight = Nothing
            , detailsHeight = Nothing
            }



-- PORTS


port openAlert : String -> Cmd msg



-- VIEW


{-| Render the alert, based on the configuration and the current state.
Handles the "alertSizes" event sent via the `openAlert` port.
-}
view : Config -> State -> Html Msg
view config state =
    let
        domId =
            config.domId

        decoder =
            resizeHandler domId state

        props =
            getProperties domId state
    in
        div
            [ id config.domId
            , class alertWrapperClass
            , style <| wrapperStylesFor props
            , on "alertSizes" decoder
            , onWithOptions "transitionend"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed <| TransitionEnd domId domId)
            ]
            [ viewContent config state ]


viewContent : Config -> State -> Html Msg
viewContent { domId, severity, dismssal, summary, details } state =
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
                , onClick (CloseClicked domId state)
                ]
                [ span
                    [ attribute "aria-hidden" "true" ]
                    -- unicode U+00D7 or &times;
                    [ text "×" ]
                ]
            , text summary
            , detailsButton domId state
            , detailsContent domId details state
            ]


detailsButton : String -> State -> Html Msg
detailsButton domId state =
    button
        [ class smallLinkButtonClass, onClick (DetailsClicked domId state) ]
        [ text "details" ]


detailsContent : String -> Maybe String -> State -> Html Msg
detailsContent domId details state =
    case details of
        Nothing ->
            emptyHtml

        Just str ->
            let
                props =
                    getProperties domId state
            in
                div
                    [ id (domId ++ "-details")
                    , classList
                        [ ( "alert-details", True )
                        , ( "open", detailsOpenFor props )
                        ]
                    , style <| detailsStylesFor props
                    , onWithOptions "transitionend"
                        { stopPropagation = True, preventDefault = True }
                        (Json.succeed <| TransitionEnd domId (domId ++ "-details"))
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


{-| Decode the height of the summary content element, which is the first
child of the wrapper element that dispatched the "alertSizes" event.
-}
wrapperHeightDecoder : Decoder Float
wrapperHeightDecoder =
    Json.at
        [ "target"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.float


{-| Decode the height of the details content element, which is the first
child of the last child of the summary content element, which is in turn,
he first child of the wrapper element that dispatched the "alertSizes" event.
-}
detailsHeightDecoder : Decoder Float
detailsHeightDecoder =
    Json.at
        [ "target"
        , "firstChild"
        , "lastChild"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.float


{-| When the "alertSizes" event is received, call this function to combine
the results of the two content element height decoders and package the results
into a "Resized" Alert.Msg value.
-}
resizeHandler : String -> State -> Decoder Msg
resizeHandler domId state =
    Json.map2 (,) wrapperHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( sHeight, dHeight ) ->
                Json.succeed <| Resized domId sHeight dHeight state
            )



-- HELPER FUNCTIONS AND CONSTANTS


emptyHtml : Html msg
emptyHtml =
    text ""


{-| Get the DOM class names for different types of alerts.
-}
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
