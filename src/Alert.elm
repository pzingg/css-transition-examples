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
        , pageChangeDismiss
        , update
        , view
        , openAlertNextFrame
        , scrollToTop
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

@docs open dismiss


# Update

@docs update


# View

@docs view


# Observing an Alert's State

@docs Visibility OutMsg

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


{-| Configuration union type describing the appearance of the Alert
(maps to Bootstrap alert styles).
-}
type Severity
    = Error
    | Info
    | Success


{-| Configuration union type describing when the Alert should be dismissed:
after a specified number of seconds, after a page change in an SPA, or
only manually (when a user clicks the close [x] button).
-}
type Dismissal
    = DismissAfter Float
    | DismissOnPageChange
    | DismissOnUserAction


{-| Configuration record for fully specifying an Alert.

  - `domId` must be a valid DOM Id string, applied to an Alert's wrapper element;
    the id string must be unique for each Alert used in the parent's model
  - `severity` specifes the Bootstrap color styles used to display the Alert
  - `dismissal` specifies whether the Alert will be automatically dismissed after a time delay
  - `summary` is the (required) string to be shown at the summary level of the Alert
  - `details` is the (optional) string to be shown when the user clicks the "details" link to expand the Alert

-}
type alias Config =
    { domId : String
    , severity : Severity
    , dismissal : Dismissal
    , summary : String
    , details : Maybe String
    }


{-| Visibility state of the Alert, passed to the application in an `OutMsg`.
-}
type Visibility
    = Hidden
    | Opening
    | Summary
    | Details
    | SummaryClosing
    | DetailsClosing


{-| Notification messages that are passed up to the application that can be used to hook
other actions.
-}
type OutMsg
    = TransitionStarted String Visibility
    | TransitionEnded String Visibility
    | DismissalTimeout String



-- PRIVATE PROPERTY TYPES


type alias Properties =
    { instanceId : Int
    , dismissal : Dismissal
    , visibility : Visibility
    , summaryHeight : Float
    , detailsHeight : Float
    }


type alias PrivateState =
    { currentId : Int
    , bag : Dict String Properties
    }


{-| Opaque type encapsulating the state of all Alerts in the parent's model.
The global state is kept in an Elm Dict keyed on the DOM ids of the Alert
wrappers.
-}
type State
    = State PrivateState



-- INIT


{-| Initialize the state of all Alerts in the model with an empty Dict.
-}
init : State
init =
    State { currentId = 0, bag = Dict.empty }



-- COMMANDS


{-| Set an Alert's visibility to `Opening`, record a new `instanceId`, and
call `openAlertNextFrame` to detect the heights of the Alert's content wells.
-}
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
                        , summaryHeight = 0
                        , detailsHeight = 0
                    }
                )
                (State { priv | currentId = instanceId })
    in
        ( nextState, Cmd.batch [ openAlertNextFrame domId, scrollToTop () ] )


{-| Click an Alert's close button programmatically.
-}
dismiss : String -> State -> ( State, Cmd msg )
dismiss domId state =
    let
        ( nextState, _ ) =
            closeClicked domId state
    in
        ( nextState, Cmd.none )


{-| Dismiss all the open alerts that have `DismissOnPageChange`.
-}
pageChangeDismiss : State -> State
pageChangeDismiss (State priv) =
    let
        dismissAlerts domId props bag =
            case ( props.dismissal, props.visibility ) of
                ( DismissOnPageChange, Details ) ->
                    Dict.insert domId { props | visibility = DetailsClosing } bag

                ( DismissOnPageChange, Summary ) ->
                    Dict.insert domId { props | visibility = SummaryClosing } bag

                _ ->
                    Dict.insert domId props bag

        nextBag =
            Dict.foldl dismissAlerts Dict.empty priv.bag
    in
        State { priv | bag = nextBag }



-- UPDATE


{-| Opaque type that handles all internal messages.
-}
type Msg
    = Resized String Dismissal Float Float
    | DetailsClicked String
    | CloseClicked String
    | TransitionEnd String String
    | DismissalTimer String Int


{-| Update function that maintains the state of all Alerts.

If Alert is just being opened (`Resized` message), returns a Cmd that will
send a `DismissalTimer` message after a desginated delay.

User actions (clicks on the close and details elements) return a `TransitionStarted` `OutMsg`.

DOM `tranistionend` events return a `TransitionEnded` `OutMsg`.

-}
update : Msg -> State -> ( State, Cmd Msg, Maybe OutMsg )
update msg state =
    case msg of
        Resized domId dismissal summaryHeight detailsHeight ->
            let
                ( nextState, props ) =
                    resized domId summaryHeight detailsHeight state
            in
                ( nextState
                , dismissalCmd domId dismissal state
                , Just <| TransitionStarted domId props.visibility
                )

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


dismissalCmd : String -> Dismissal -> State -> Cmd Msg
dismissalCmd domId dismissal state =
    let
        instanceId =
            getProperties domId state
                |> .instanceId
    in
        case dismissal of
            DismissAfter time ->
                delay time (DismissalTimer domId instanceId)

            _ ->
                Cmd.none


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
                                , summaryHeight = sHeight
                                , detailsHeight = dHeight
                            }

                        _ ->
                            { props
                                | summaryHeight = sHeight
                                , detailsHeight = dHeight
                            }
                )
                state
    in
        ( nextState, props )


detailsClicked : String -> State -> ( State, Properties )
detailsClicked domId state =
    mapProperties domId
        (\props ->
            case props.visibility of
                Summary ->
                    { props | dismissal = removeTimer props.dismissal, visibility = Details }

                Details ->
                    { props | dismissal = removeTimer props.dismissal, visibility = Summary }

                _ ->
                    props
        )
        state


closeClicked : String -> State -> ( State, Properties )
closeClicked domId state =
    mapProperties domId
        (\props ->
            case props.visibility of
                Details ->
                    { props | dismissal = removeTimer props.dismissal, visibility = DetailsClosing }

                Summary ->
                    { props | dismissal = removeTimer props.dismissal, visibility = SummaryClosing }

                _ ->
                    props
        )
        state


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
            case ( props.dismissal, props.instanceId == instanceId, props.visibility ) of
                ( DismissAfter _, True, Details ) ->
                    ( { props | visibility = DetailsClosing }, True )

                ( DismissAfter _, True, Summary ) ->
                    ( { props | visibility = SummaryClosing }, True )

                _ ->
                    ( props, False )

        nextPriv =
            { priv | bag = Dict.insert domId nextProperties priv.bag }
    in
        ( State nextPriv, wasDismissed )


getProperties : String -> State -> Properties
getProperties domId (State priv) =
    Dict.get domId priv.bag
        |> Maybe.withDefault
            { instanceId = priv.currentId
            , dismissal = DismissOnUserAction
            , visibility = Hidden
            , summaryHeight = 0
            , detailsHeight = 0
            }


mapProperties : String -> (Properties -> Properties) -> State -> ( State, Properties )
mapProperties domId f ((State priv) as state) =
    let
        nextProperties =
            f <| getProperties domId state

        nextPriv =
            { priv | bag = Dict.insert domId nextProperties priv.bag }
    in
        ( State nextPriv, nextProperties )


removeTimer : Dismissal -> Dismissal
removeTimer dismissal =
    case dismissal of
        DismissAfter _ ->
            DismissOnUserAction

        _ ->
            dismissal



-- PORTS


{-| JavaScript port that simply dispatches an `alertSizes` CustomEvent
on the element with the specified DOM Id. The version in this example
uses `requestAnimationFrame` to delay the dispatch for one animation cycle,
in order to allow the initial state to be rendered on the VDOM.
-}
port openAlertNextFrame : String -> Cmd msg


{-| JavaScript port that uses CSSOM smooth scrolling behavior.
-}
port scrollToTop : () -> Cmd msg



-- VIEW


{-| Render an Alert, based on the configuration and the current visibility.
Handles DOM events:

  - `click` on close and details elements
  - `alertSizes` event sent via the `openAlertNextFrame` port
  - `transitionend` event dispatched when CSS transition is finished

-}
view : Config -> State -> Html Msg
view ({ domId, dismissal } as config) state =
    div
        [ id domId
        , class alertWrapperClass
        , style <| wrapperStylesFor <| getProperties domId state
        , on "alertSizes" <| resizeHandler domId dismissal
        , onWithOptions "transitionend"
            { stopPropagation = True, preventDefault = True }
            (TransitionEnd domId domId |> Json.succeed)
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
            [ ( "height", toString (summaryHeight + 10) ++ "px" ) ]

        Details ->
            [ ( "height", toString (summaryHeight + detailsHeight + 20) ++ "px" ) ]

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
            [ ( "height", toString (detailsHeight + 10) ++ "px" ) ]

        _ ->
            [ ( "height", "0px" ) ]


{-| Decode the height of the summary content element, which is the first
child of the wrapper element that dispatched the `alertSizes` event.
-}
summaryHeightDecoder : Decoder Float
summaryHeightDecoder =
    Json.at
        [ "target"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.float


{-| Decode the height of the details content element, which is the first
child of the last child of the summary content element, which is in turn,
he first child of the wrapper element that dispatched the `alertSizes` event.
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


{-| When the `alertSizes` event is received, call this function to combine
the results of the two content element height decoders and package the results
into a "Resized" Alert.Msg value.
-}
resizeHandler : String -> Dismissal -> Decoder Msg
resizeHandler domId dismissal =
    Json.map2 (,) summaryHeightDecoder detailsHeightDecoder
        |> Json.andThen
            (\( summaryHeight, detailsHeight ) ->
                Resized domId dismissal summaryHeight detailsHeight
                    |> Json.succeed
            )



-- HELPER FUNCTIONS AND CONSTANTS


{-| Use Process.sleep Task to send a message some time in the future.
-}
delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


emptyHtml : Html msg
emptyHtml =
    text ""


{-| Get the DOM class names for different types of Alerts.
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
    "alert-wrapper"


alertErrorClass : String
alertErrorClass =
    "alert alert-danger alert-dismissable error"


alertInfoClass : String
alertInfoClass =
    "alert alert-info alert-dismissable info"


alertSuccessClass : String
alertSuccessClass =
    "alert alert-success alert-dismissable success"
