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
        , dismiss
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
import Process
import Task
import Time exposing (Time)


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
    , dismissal : Dismissal
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
    | DismissalTimeout String



-- PRIVATE PROPERTY TYPES


type alias Properties =
    { instanceId : Int
    , dismissal : Dismissal
    , visibility : Visibility
    , summaryHeight : Maybe Float
    , detailsHeight : Maybe Float
    }


type alias PrivateState =
    { currentId : Int
    , bag : Dict String Properties
    }


{-| Opaque type encapsulating the state of all alerts in the parent's model.
The global state is kept in an Elm Dict keyed on the DOM ids of the alert
wrappers.
-}
type State
    = State PrivateState



-- INIT


{-| Initialize the state of all alerts in the model with an empty Dict.
-}
init : State
init =
    State { currentId = 0, bag = Dict.empty }



-- COMMANDS


open : Config -> State -> ( State, Cmd msg )
open { domId, dismissal } ((State priv) as state) =
    let
        instanceId =
            priv.currentId + 1

        ( nextState, _ ) =
            mapProperties domId
                (\props ->
                    { props
                        | instanceId = instanceId
                        , dismissal = dismissal
                        , visibility = Opening
                        , summaryHeight = Nothing
                        , detailsHeight = Nothing
                    }
                )
                (State { priv | currentId = instanceId })
    in
        ( nextState, openAlert domId )


dismiss : String -> State -> ( State, Cmd msg )
dismiss domId state =
    let
        ( nextState, _ ) =
            closeClicked domId state
    in
        ( nextState, Cmd.none )



-- UPDATE


{-| Opaque type that handles all internal messages.
-}
type Msg
    = Resized String Dismissal Float Float
    | DetailsClicked String
    | CloseClicked String
    | TransitionEnd String String
    | DismissalTimer String Int


{-| Update function.
-}
update : Msg -> State -> ( State, Cmd Msg, Maybe OutMsg )
update msg state =
    case msg of
        Resized domId dismissal sHeight dHeight ->
            let
                instanceId =
                    getProperties domId state
                        |> .instanceId

                dismissalCmd =
                    case dismissal of
                        DismissAfter time ->
                            delay time (DismissalTimer domId instanceId)

                        _ ->
                            Cmd.none

                ( nextState, props ) =
                    resized domId sHeight dHeight state
            in
                ( nextState, dismissalCmd, Just <| TransitionStarted domId props.visibility )

        DetailsClicked domId ->
            let
                ( nextState, props ) =
                    detailsClicked domId state
            in
                ( nextState, Cmd.none, Just <| TransitionStarted domId props.visibility )

        CloseClicked domId ->
            let
                ( nextState, props ) =
                    closeClicked domId state
            in
                ( nextState, Cmd.none, Just <| TransitionStarted domId props.visibility )

        TransitionEnd domId componentId ->
            let
                ( nextState, props ) =
                    transitionEnd domId state
            in
                ( nextState, Cmd.none, Just <| TransitionEnded componentId props.visibility )

        DismissalTimer domId instanceId ->
            let
                ( nextState, wasDismissed ) =
                    dismissalTimer domId instanceId state
            in
                case wasDismissed of
                    True ->
                        ( nextState, Cmd.none, Just <| DismissalTimeout domId )

                    False ->
                        ( nextState, Cmd.none, Nothing )


resized : String -> Float -> Float -> State -> ( State, Properties )
resized domId sHeight dHeight state =
    let
        ( nextState, props ) =
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
        ( nextState, props )


detailsClicked : String -> State -> ( State, Properties )
detailsClicked domId state =
    let
        ( nextState, props ) =
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
        ( nextState, props )


closeClicked : String -> State -> ( State, Properties )
closeClicked domId state =
    let
        ( nextState, props ) =
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
        ( nextState, props )


transitionEnd : String -> State -> ( State, Properties )
transitionEnd domId ((State priv) as state) =
    let
        props =
            getProperties domId state

        nextProperties =
            case props.visibility of
                DetailsClosing ->
                    { props | visibility = Hidden }

                SummaryClosing ->
                    { props | visibility = Hidden }

                _ ->
                    props

        nextPriv =
            case nextProperties.visibility of
                Hidden ->
                    { priv | bag = Dict.remove domId priv.bag }

                _ ->
                    { priv | bag = Dict.insert domId nextProperties priv.bag }
    in
        ( State nextPriv, nextProperties )


dismissalTimer : String -> Int -> State -> ( State, Bool )
dismissalTimer domId instanceId ((State priv) as state) =
    let
        props =
            getProperties domId state

        ( nextProperties, wasDismissed ) =
            case ( props.instanceId == instanceId, props.visibility ) of
                ( True, Details ) ->
                    ( { props | visibility = DetailsClosing }, True )

                ( True, Summary ) ->
                    ( { props | visibility = SummaryClosing }, True )

                _ ->
                    ( props, False )

        nextPriv =
            { priv | bag = Dict.insert domId nextProperties priv.bag }
    in
        ( State nextPriv, wasDismissed )


mapProperties : String -> (Properties -> Properties) -> State -> ( State, Properties )
mapProperties domId mapperFn ((State priv) as state) =
    let
        nextProperties =
            getProperties domId state
                |> mapperFn

        nextPriv =
            { priv | bag = Dict.insert domId nextProperties priv.bag }
    in
        ( State nextPriv, nextProperties )


getProperties : String -> State -> Properties
getProperties domId (State state) =
    Dict.get domId state.bag
        |> Maybe.withDefault
            { instanceId = state.currentId
            , dismissal = DismissOnUserAction
            , visibility = Hidden
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
            resizeHandler domId config.dismissal

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
viewContent { domId, severity, dismissal, summary, details } state =
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
                , onClick (CloseClicked domId)
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
        [ class smallLinkButtonClass, onClick (DetailsClicked domId) ]
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
resizeHandler : String -> Dismissal -> Decoder Msg
resizeHandler domId dismissal =
    Json.map2 (,) wrapperHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( sHeight, dHeight ) ->
                Json.succeed <| Resized domId dismissal sHeight dHeight
            )



-- HELPER FUNCTIONS AND CONSTANTS


{-| Send a message some time in the future.
-}
delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


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
