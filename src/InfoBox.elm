module InfoBox
    exposing
        ( Visibility(..)
        , OutMsg(..)
        , Config
        , State
        , Msg
        , init
        , update
        , view
        )

{-| This module encapsulates the behavior of an Elm "InfoBox" component.
An InfoBox consists of an HTML header line ("h2", "h3", etc), with a (?)
icon that when clicked, expands with animation to reveal a Bootstrap "well"
containing information for the user.


# Configuration

@docs Config


# Initialization

@docs init


# Commands

@docs open


# Update

@docs update


# View

@docs view


# Observing an InfoBox's State

@docs Visibility OutMsg

-}

import Dict exposing (Dict)
import Html exposing (Html, node, text, div, i)
import Html.Attributes exposing (id, class, style)
import Html.Events exposing (onWithOptions)
import Json.Decode as Json exposing (Decoder, field)


-- CONFIGURATION


{-| Configuration record for fully specifying an info box.

  - `domId` must be a valid DOM Id string, applied to an info box's header
    element; the id string must be unique for each info box used in the parent's model
  - `tagName` should be a "header" tag element type, such as "h2", "h3", "h4";
    the tag type will be appled to the header text.
  - `htext` is the (required) string for the header text
  - `content` is the Elm HTML content that is initially hidden but displayed
    when the user clicks the (?) icon in the header.

-}
type alias Config =
    { domId : String
    , tagName : String
    , htext : String
    , content : Html Msg
    }



-- PUBLIC PROPERTIES AND OUTMESSAGES


{-| The InfoBox's current or transitioning visibility.
-}
type Visibility
    = Hidden
    | Shown


{-| Notification messages that are passed up to the application that can be used to hook
other actions.

  - `TransitionStarted` sent when user clicks the open/close icon
  - `TransitionEnded` sent when the CSS transition finishes

-}
type OutMsg
    = TransitionStarted String Visibility
    | TransitionEnded String Visibility



-- PRIVATE PROPERTIES


type alias Properties =
    { visibility : Visibility
    , height : Maybe Float
    }


type alias PrivateState =
    Dict String Properties


{-| Opaque type encapsulating the state of all info boxes in the parent's model.
The global state is kept in an Elm Dict keyed on the DOM ids of the info box
headers.
-}
type State
    = State PrivateState



-- INIT


{-| Initialize the state of all InfoBoxes in the model with an empty Dict.
-}
init : State
init =
    State Dict.empty



-- UPDATE


{-| Opaque type that handles all internal messages.
-}
type Msg
    = IconClicked String Float
    | TransitionEnd String


{-| Update function that maintains state of all InfoBoxes.

User actions (clicks on the close and details elements) return a `TransitionStarted` `OutMsg`.

DOM `tranistionend` events return a `TransitionEnded` `OutMsg`.

-}
update : Msg -> State -> ( State, Maybe OutMsg )
update msg ((State bag) as state) =
    case msg of
        IconClicked domId height ->
            let
                props =
                    getProperties domId state

                nextProperties =
                    { props
                        | height = Just height
                        , visibility = toggleVisibility props.visibility
                    }

                nextBag =
                    Dict.insert domId nextProperties bag
            in
                ( State nextBag, Just <| TransitionStarted domId nextProperties.visibility )

        TransitionEnd domId ->
            let
                props =
                    getProperties domId state
            in
                ( state, Just <| TransitionEnded domId props.visibility )


toggleVisibility : Visibility -> Visibility
toggleVisibility visibility =
    case visibility of
        Shown ->
            Hidden

        _ ->
            Shown


getProperties : String -> State -> Properties
getProperties domId (State bag) =
    Dict.get domId bag
        |> Maybe.withDefault
            { visibility = Hidden
            , height = Nothing
            }



-- VIEW


{-| Render the info box, based on the configuration and the current state.
A click on the icon contained in the header diapatches a click event to
the iconClickHander function.
-}
view : Config -> State -> Html Msg
view { domId, tagName, htext, content } state =
    let
        ( class_, style_ ) =
            classAndStyle <| getProperties domId state
    in
        div [ class "info-box" ]
            [ node tagName
                []
                [ text htext
                , i
                    [ class "glyphicon glyphicon-question-sign help-icon"
                    , onWithOptions "click"
                        { stopPropagation = False, preventDefault = True }
                        (iconClickHandler domId)
                    ]
                    []
                ]
            , div
                [ id domId
                , class class_
                , style style_
                , onWithOptions "transitionend"
                    { stopPropagation = False, preventDefault = True }
                    (Json.succeed <| TransitionEnd domId)
                ]
                [ div [ class "well content" ]
                    [ content ]
                ]
            ]


classAndStyle : Properties -> ( String, List ( String, String ) )
classAndStyle { visibility, height } =
    let
        ( wrapperClass, wrapperHeight ) =
            case ( visibility, height ) of
                ( Hidden, _ ) ->
                    ( "info-box-wrapper", "0px" )

                ( _, Nothing ) ->
                    ( "info-box-wrapper", "0px" )

                ( _, Just h ) ->
                    ( "info-box-wrapper open", (toString h) ++ "px" )
    in
        ( wrapperClass, [ ( "height", wrapperHeight ) ] )


iconClickHandler : String -> Decoder Msg
iconClickHandler domId =
    wellHeightDecoder
        |> Json.andThen (\height -> Json.succeed <| IconClicked domId height)


{-| Decode the height of the content element, which is the first
child of the info box's wrapper element. The wrapper element is the
next sibling of the parent of the icon that dispatched the click event.

Using the DOM libary, you could also write this as:

    wellHeightDecoder =
        -- i (the click handler target)
        DOM.target
            (-- h2, h3 or h4
             DOM.parentElement
                (-- infoBoxWrapper div
                 DOM.nextSibling
                    (-- get offsetHeight of well div
                     DOM.childNode 0 DOM.offsetHeight
                    )
                )
            )

-}
wellHeightDecoder : Decoder Float
wellHeightDecoder =
    Json.at
        [ "target"
        , "parentElement"
        , "nextSibling"
        , "firstChild"
        , "offsetHeight"
        ]
        Json.float
