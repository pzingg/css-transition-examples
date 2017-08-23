module AlertExample.Main exposing (main)

import Html exposing (Html, program, text, div, h1, h2, h3, h4, a, p, nav, ul, li)
import Html.Attributes exposing (attribute, class, style, href)
import Html.Events exposing (onClick)
import Time
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
                    Alert.open config model.alerts
            in
                ( { model | alerts = nextState, index = i }, alertCmd )

        DismissAlert i ->
            let
                config =
                    exampleAlert i

                ( nextState, alertCmd ) =
                    Alert.dismiss config.domId model.alerts
            in
                ( { model | alerts = nextState }, alertCmd )

        AlertMsg subMsg ->
            let
                ( nextState, subCmd, maybeMsg ) =
                    Alert.update subMsg model.alerts

                nextModel =
                    { model | alerts = nextState }
            in
                case maybeMsg of
                    Nothing ->
                        ( nextModel, Cmd.map AlertMsg subCmd )

                    -- Alert.OutMsg handling can be used to schedule other actions
                    -- Alert.TranstionStarted
                    -- Alert.TransitionEnded
                    -- Alert.DismissalTimeout
                    Just outMsg ->
                        let
                            _ =
                                Debug.log "OutMsg" outMsg
                        in
                            ( nextModel, Cmd.map AlertMsg subCmd )



-- VIEW


exampleAlert : Int -> Alert.Config
exampleAlert i =
    case i % 4 of
        1 ->
            { domId = "my-alert"
            , severity = Error
            , dismissal = DismissOnUserAction
            , summary = "OMG. Something bad happened. You'll have to close this alert yourself."
            , details = Just "And you expanded the details content."
            }

        2 ->
            { domId = "my-alert"
            , severity = Success
            , dismissal = DismissAfter (5 * Time.second)
            , summary = "A button was clicked again."
            , details = Just "And you expanded the details content."
            }

        3 ->
            { domId = "my-alert"
            , severity = Success
            , dismissal = DismissAfter (5 * Time.second)
            , summary = "Changed the summary text."
            , details = Just "And you expanded the details content."
            }

        _ ->
            { domId = "my-alert"
            , severity = Info
            , dismissal = DismissAfter (5 * Time.second)
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
                [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam risus tellus, maximus ut iaculis non, rhoncus sit amet nisl. Quisque nec nisl convallis, lobortis orci vel, volutpat velit. Proin sed commodo purus, in lobortis mauris. Curabitur commodo commodo luctus. Aenean et tellus eu urna rhoncus accumsan. Aenean sed magna massa. Sed a pulvinar ante, eget sagittis tellus." ]
            , p []
                [ text "ibulum malesuada, odio nisi imperdiet sapien, semper semper lorem massa gravida risus. Quisque massa lectus, gravida at posuere vel, tristique vitae purus. In molestie, lorem vel placerat tempor, augue sem ultrices mi, et commodo ante lorem non lorem. In accumsan, justo eget hendrerit facilisis, diam erat sagittis mi, at bibendum est ante ac ante. Vivamus rhoncus faucibus velit, id elementum risus mattis sed. Ut odio metus, vulputate sit amet feugiat eu, fermentum in neque. Mauris sollicitudin vehicula tortor, a mollis libero aliquet sed. Donec venenatis erat eu lacus lacinia, quis lacinia lectus blandit." ]
            , p []
                [ text "Phasellus ac massa sed est tempus feugiat. Vivamus ultricies commodo urna vitae ultrices. Proin tincidunt felis non lectus vestibulum, non scelerisque lectus auctor. Cras vel mi elit. Morbi porta non nunc ac rutrum. Etiam auctor elementum hendrerit. Nulla quis imperdiet nisl, ut porta tellus. Fusce nec nibh feugiat, euismod odio eget, cursus purus. Donec nec consequat purus, at euismod orci. Nulla ac dictum sem. Nunc blandit et augue vel malesuada." ]
            , p []
                [ text "Aliquam erat volutpat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nulla sapien ante, varius at sapien ac, accumsan mollis risus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Pellentesque blandit quam quis luctus condimentum. Nam mattis egestas nulla et lobortis. Ut consequat nisi id maximus pretium. Proin venenatis aliquet molestie. Pellentesque mattis dui augue, nec laoreet tellus accumsan in. Sed ornare egestas ipsum sodales accumsan. Pellentesque aliquam vulputate lacinia. Donec rutrum mi neque. Nam sed mauris quis lorem varius dictum." ]
            , p []
                [ text "Cras mauris diam, lacinia vitae dolor sit amet, dignissim molestie velit. Vestibulum enim nibh, condimentum vestibulum orci non, dapibus luctus turpis. Donec molestie ligula risus, a tincidunt metus ultrices id. Morbi eu posuere metus. Aliquam ac pulvinar sapien. Duis in velit et augue suscipit tincidunt iaculis ac velit. Fusce nec sem ante." ]
            , p []
                [ text "Duis quam est, dapibus vitae tincidunt a, maximus sit amet metus. Donec vitae lacinia sapien. Aenean sem sapien, mattis id hendrerit et, efficitur vel quam. Pellentesque tellus mi, rutrum non dolor a, scelerisque lobortis arcu. Sed et euismod risus, a facilisis justo. Nam facilisis, arcu eu tempus aliquet, tortor libero maximus lacus, faucibus dignissim felis lacus vitae dolor. Quisque ornare eros nulla, nec varius ex luctus nec. In sit amet sem velit. Donec non felis sed ipsum scelerisque tempor. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nunc euismod felis in nisi tincidunt suscipit. Suspendisse pulvinar lectus eget orci elementum, vehicula ultricies neque vestibulum. Duis sollicitudin augue sed ornare volutpat. In volutpat ipsum est. Duis dapibus, est id tempor porta, est ligula sodales arcu, sit amet vehicula nibh enim sollicitudin neque. Maecenas eleifend iaculis quam in fringilla." ]
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
