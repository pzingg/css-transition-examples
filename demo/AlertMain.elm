module AlertMain exposing (main)

import Html exposing (Html, program, text, div, h1, h2, h3, h4, a, p, nav, ul, li)
import Html.Attributes exposing (attribute, class, style, href)
import Html.Events exposing (onClick)
import Alert exposing (..)


-- MODEL


type alias Model =
    { alerts : Alert.State
    , index : Int
    }



-- MSG


type Msg
    = NoOp
    | ShowAlert Int
    | DismissAlert Int
    | AlertMsg Alert.Msg



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { alerts = Alert.init, index = 0 }, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ShowAlert i ->
            let
                config =
                    exampleAlert i

                ( nextState, alertCmd ) =
                    Alert.open config.domId model.alerts
            in
                ( { model | alerts = nextState, index = i }, alertCmd )

        DismissAlert i ->
            let
                config =
                    exampleAlert i

                ( nextState, alertCmd ) =
                    Alert.dismiss config.domId model.alerts
            in
                ( { model | alerts = nextState, index = i }, alertCmd )

        AlertMsg subMsg ->
            let
                ( nextState, maybeMsg ) =
                    Alert.update subMsg model.alerts

                nextModel =
                    { model | alerts = nextState }
            in
                case maybeMsg of
                    Nothing ->
                        ( nextModel, Cmd.none )

                    -- Alert.TranstionStarted or Alert.TransitionEnded messages
                    Just outMsg ->
                        let
                            _ =
                                Debug.log "OutMsg" outMsg
                        in
                            ( nextModel, Cmd.none )



-- VIEW


exampleAlert : Int -> Alert.Config
exampleAlert i =
    case i % 3 of
        1 ->
            { domId = "alert-error"
            , severity = Error
            , dismssal = DismissAfter 5
            , summary = "OMG. Something bad happened."
            , details = Just "And you expanded the details content."
            }

        2 ->
            { domId = "alert-success"
            , severity = Success
            , dismssal = DismissAfter 5
            , summary = "A button was clicked again."
            , details = Just "And you expanded the details content."
            }

        _ ->
            { domId = "alert-info"
            , severity = Info
            , dismssal = DismissAfter 5
            , summary = "You just clicked something. Hurray!"
            , details = Just "And you expanded the details content. Double hurray!"
            }


view : Model -> Html Msg
view model =
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
        , Alert.view (exampleAlert model.index) model.alerts
            |> Html.map AlertMsg
        , div [ class "jumbotron" ]
            [ h2 []
                [ text "Alert Example" ]
            , p [ class "lead" ]
                [ text "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus." ]
            , p []
                [ a
                    [ class "btn btn-lg btn-success"
                    , href "#"
                    , attribute "role" "button"
                    , onClick <| ShowAlert (model.index + 1)
                    ]
                    [ text "Next Alert" ]
                , a
                    [ class "btn btn-lg btn-info"
                    , style [ ( "margin-left", "10px" ) ]
                    , href "#"
                    , attribute "role" "button"
                    , onClick <| DismissAlert model.index
                    ]
                    [ text "Dismiss Alert" ]
                ]
            ]
        , div [ class "row marketing" ]
            [ h3 []
                [ text "Alerts need to use ports" ]
            , p []
                [ text "Donec id elit non mi porta gravida at eget metus. Maecenas faucibus mollis interdum." ]
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
