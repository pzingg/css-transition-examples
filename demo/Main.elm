module Main exposing (main)

import Html exposing (Html, program, text, div, h1, h2, h3, h4, a, p, nav, ul, li)
import Html.Attributes exposing (attribute, class, href)


-- MODEL


type alias Model =
    String



-- MSG


type Msg
    = NoOp



-- INIT


init : ( Model, Cmd Msg )
init =
    ( "Hello", Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view _ =
    div [ class "container" ]
        [ div [ class "header clearfix" ]
            [ nav []
                [ ul [ class "nav nav-pills pull-right" ]
                    [ li [ class "active", attribute "role" "presentation" ]
                        [ a [ href "#" ]
                            [ text "Home" ]
                        ]
                    , li [ attribute "role" "presentation" ]
                        [ a [ href "#" ]
                            [ text "About" ]
                        ]
                    , li [ attribute "role" "presentation" ]
                        [ a [ href "#" ]
                            [ text "Contact" ]
                        ]
                    ]
                ]
            , h3 [ class "text-muted" ]
                [ text "CSS Transitions in Elm" ]
            ]
        , div [ class "jumbotron" ]
            [ h1 []
                [ text "Jumbotron heading" ]
            , p [ class "lead" ]
                [ text "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus." ]
            , p []
                [ a [ class "btn btn-lg btn-success", href "#", attribute "role" "button" ]
                    [ text "Sign up today" ]
                ]
            ]
        , div [ class "row marketing" ]
            [ div [ class "col-lg-6" ]
                [ h4 []
                    [ text "Subheading" ]
                , p []
                    [ text "Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum." ]
                ]
            , div [ class "col-lg-6" ]
                [ h4 []
                    [ text "Subheading" ]
                , p []
                    [ text "Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum." ]
                ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- PROGRAM


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
