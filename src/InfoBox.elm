module InfoBox exposing (Config, State, init, iconClicked, view)

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
import Html exposing (Html, node, text, div, i)
import Html.Attributes exposing (id, class, style)
import Html.Events exposing (onWithOptions)
import Json.Decode as Json


-- TYPES


type alias Config msg =
    { domId : String
    , tagName : String
    , htext : String
    , content : Html msg
    , tagger : String -> Float -> State -> msg
    }


type Visibility
    = Hidden
    | Shown


type alias Properties =
    { visibility : Visibility
    , height : Maybe Float
    }


type State
    = State (Dict String Properties)



-- INIT


init : State
init =
    State Dict.empty



-- UPDATE


iconClicked : String -> Float -> State -> State
iconClicked domId height state =
    mapProperties domId
        (\props ->
            { props
                | height = Just height
                , visibility = toggleVisibility props.visibility
            }
        )
        state


mapProperties : String -> (Properties -> Properties) -> State -> State
mapProperties domId mapperFn ((State boxProps) as state) =
    let
        updateProperties =
            getProperties domId state
                |> mapperFn
    in
        State (Dict.insert domId updateProperties boxProps)


toggleVisibility : Visibility -> Visibility
toggleVisibility visibility =
    case visibility of
        Shown ->
            Hidden

        _ ->
            Shown


getProperties : String -> State -> Properties
getProperties domId (State boxProps) =
    Dict.get domId boxProps
        |> Maybe.withDefault
            { visibility = Hidden
            , height = Nothing
            }



-- VIEW


view : Config msg -> State -> Html msg
view { tagName, domId, tagger, htext, content } state =
    let
        { visibility, height } =
            getProperties domId state

        ( wrapperClass, wrapperHeight ) =
            case ( visibility, height ) of
                ( Hidden, _ ) ->
                    ( "info-box-wrapper", "0" )

                ( _, Nothing ) ->
                    ( "info-box-wrapper", "0" )

                ( _, Just h ) ->
                    ( "info-box-wrapper open", (toString h) ++ "px" )
    in
        div []
            [ node tagName
                []
                [ text htext
                , i
                    [ class "glyphicon glyphicon-question-sign help-icon"
                    , onWithOptions "click"
                        { stopPropagation = False, preventDefault = True }
                        (iconClickHandler domId state tagger)
                    ]
                    []
                ]
            , div
                [ id domId
                , class wrapperClass
                , style [ ( "height", wrapperHeight ) ]
                ]
                [ div [ class "well content" ]
                    [ content ]
                ]
            ]


iconClickHandler : String -> State -> (String -> Float -> State -> msg) -> Json.Decoder msg
iconClickHandler domId state tagger =
    wellHeightDecoder
        |> Json.andThen (\height -> Json.succeed (tagger domId height state))


wellHeightDecoder : Json.Decoder Float
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
