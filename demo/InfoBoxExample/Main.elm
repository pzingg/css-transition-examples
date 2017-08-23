module InfoBoxExample.Main exposing (main)

import Html exposing (Html, program, text, div, h1, h2, h3, h4, a, p, nav, ul, li)
import Html.Attributes exposing (attribute, class, href)
import InfoBox


-- MODEL


type alias Model =
    { infoBoxes : InfoBox.State
    }



-- MSG


type Msg
    = NoOp
    | InfoBoxMsg InfoBox.Msg



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { infoBoxes = InfoBox.init }, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        InfoBoxMsg subMsg ->
            let
                ( nextState, maybeMsg ) =
                    InfoBox.update subMsg model.infoBoxes

                nextModel =
                    { model | infoBoxes = nextState }
            in
                case maybeMsg of
                    Nothing ->
                        ( nextModel, Cmd.none )

                    -- InfoBox.OutMsg handling can be used to schedule other actions
                    -- InfoBox.TranstionStarted
                    -- InfoBox.TransitionEnded
                    Just outMsg ->
                        let
                            _ =
                                Debug.log "OutMsg" outMsg
                        in
                            ( nextModel, Cmd.none )



-- VIEW


ibExampleConfig : InfoBox.Config
ibExampleConfig =
    { domId = "ib-example"
    , tagName = "h3"
    , htext = "Click here to get more information"
    , content =
        div [] [ text "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus." ]
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
        , div [ class "jumbotron" ]
            [ h2 []
                [ text "Info Box Example" ]
            , p [ class "lead" ]
                [ text "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus." ]
            , p []
                [ a [ class "btn btn-lg btn-success", href "#", attribute "role" "button" ]
                    [ text "Sign up today" ]
                ]
            ]
        , div [ class "row marketing" ]
            [ div [ class "col-lg-12" ]
                [ InfoBox.view ibExampleConfig model.infoBoxes
                    |> Html.map InfoBoxMsg
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
