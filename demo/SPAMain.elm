module SPAMain exposing (..)

import Html exposing (Html, Attribute, div, nav, ul, li, a, h1, h2, h3, h4, p, text)
import Html.Attributes exposing (class, href, attribute)
import Html.Events exposing (onWithOptions)
import Json.Decode as Json
import Navigation
import UrlParser


-- MESSAGES


{-|

  - ChangeLocation will be used for initiating a url change
  - OnLocationChange will be triggered after a location change
-}
type Msg
    = ChangeLocation String
    | OnLocationChange Navigation.Location



-- MODELS


{-|

  - `route` will hold the current matched route
  - `changes` is just here to prove that we are not reloading the page and wiping out the app state
-}
type alias Model =
    { route : Route
    , changes : Int
    }


{-| initialModel will be called with the current matched route.
We store this in the model so we can display the corrent view.
-}
initialModel : Route -> Model
initialModel route =
    { route = route
    , changes = 0
    }



-- ROUTING


{-| This are our available routes
NotFoundRoute will be used when we cannot match a route.
-}
type Route
    = HomeRoute
    | AboutRoute
    | NotFoundRoute


{-| Define how to match urls
-}
matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map HomeRoute UrlParser.top
        , UrlParser.map AboutRoute (UrlParser.s "about")
        ]


{-| Match a location given by the Navigation package and return the matched route.
-}
parseLocation : Navigation.Location -> Route
parseLocation location =
    case (UrlParser.parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


homePath : String
homePath =
    "#/"


aboutPath : String
aboutPath =
    "#/about"



-- UPDATE


{-| On `ChangeLocation` call `Navigation.newUrl` to create a command that will change the browser location.

`OnLocationChange` will be called each time the browser location changes.
In this case we store the new route in the Model.

-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeLocation hash ->
            ( { model | changes = model.changes + 1 }, Navigation.newUrl hash )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )



-- VIEWS


view : Model -> Html Msg
view model =
    div [ class "container" ]
        ([ div
            [ class "header clearfix" ]
            [ navbar model
            , h3
                [ class "text-muted" ]
                [ text "CSS Transitions in Elm" ]
            ]
         ]
            ++ page model
        )


{-| When clicking a link we want to prevent the default browser behaviour which is to load a new page.
So we use `onWithOptions` instead of `onClick`.
-}
onLinkClick : msg -> Attribute msg
onLinkClick message =
    onWithOptions "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.succeed message)


{-| We want our links to show a proper href e.g. "/about", so we include an href attribute.
onLinkClick will prevent the browser reloading the page.
-}
navbar : Model -> Html Msg
navbar model =
    nav []
        [ ul [ class "nav nav-pills pull-right" ]
            [ li [ class "active", attribute "role" "presentation" ]
                [ a [ href homePath, onLinkClick (ChangeLocation homePath) ]
                    [ text "Home" ]
                ]
            , li [ attribute "role" "presentation" ]
                [ a [ href aboutPath, onLinkClick (ChangeLocation aboutPath) ]
                    [ text "About" ]
                ]
            , li [ attribute "role" "presentation" ]
                [ a [ href "#" ]
                    [ text "Contact" ]
                ]
            ]
        ]


{-| Decide what to show based on the current `model.route`
-}
page : Model -> List (Html Msg)
page model =
    [ div [ class "jumbotron" ]
        [ h1 []
            [ pageText model ]
        , p [ class "lead" ]
            [ text "Cras justo odio, dapibus ac facilisis in, egestas eget quam. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus." ]
        , p []
            [ a [ class "btn btn-lg btn-success", href "#", attribute "role" "button" ]
                [ text "Sign up today" ]
            ]
        ]
    , div [ class "row marketing" ]
        [ div [ class "col-lg-12" ]
            [ h4 []
                [ pageText model ]
            , p []
                [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet tellus tincidunt, auctor orci quis, porttitor ex. Sed sed varius magna, in mollis mauris. Nullam pharetra lacus justo, sed placerat est elementum sit amet. Aliquam fermentum eu est eu ullamcorper. Sed magna eros, dictum eget ligula vel, pellentesque blandit eros. Aenean euismod ante in aliquet cursus. Pellentesque et ultricies libero. Duis malesuada velit quam, sed pharetra ipsum volutpat nec. Donec eu mauris eros. In hac habitasse platea dictumst. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce molestie, nibh id semper pretium, velit tellus pellentesque mauris, nec bibendum erat diam quis ligula. In volutpat elementum vulputate. Morbi rutrum enim nisi, sit amet faucibus urna facilisis sit amet. Praesent tortor libero, hendrerit vel vulputate ac, sagittis sit amet quam. Etiam ligula justo, semper in risus non, elementum scelerisque sem." ]
            , p []
                [ text "Nunc laoreet, orci sit amet euismod pretium, tortor tellus pellentesque mauris, vitae suscipit enim augue eget arcu. Morbi hendrerit est quis urna porta, eu tincidunt turpis porttitor. Nullam hendrerit a neque a consequat. Vivamus neque metus, vehicula cursus eros vel, consectetur fringilla est. Praesent dapibus aliquet ex sed rhoncus. Cras vel eleifend enim. Duis sollicitudin, eros non tempus bibendum, felis lorem cursus massa, vel ultricies ex enim et velit. Nam tincidunt neque eget dignissim maximus. Ut eu velit rutrum, feugiat tortor et, elementum nulla. Pellentesque dolor libero, iaculis non efficitur ac, finibus eu lacus." ]
            , p []
                [ text "Morbi a vulputate magna. Donec mattis mauris quis dui venenatis facilisis. Proin imperdiet, justo eu feugiat lobortis, nunc velit consequat lorem, et pharetra justo mauris ut lorem. Maecenas consequat velit sed nisl facilisis, ac semper velit cursus. Cras non leo non eros sollicitudin luctus. Aliquam cursus libero at elit tincidunt imperdiet. Donec luctus luctus laoreet. Cras eleifend lacus vitae lorem porttitor, pellentesque tincidunt felis ornare. Sed in fringilla sapien, vitae imperdiet magna. Phasellus vitae est nisi. Praesent quis sapien dignissim, aliquet nulla id, suscipit urna. Etiam vel neque diam. Suspendisse velit tellus, molestie non efficitur quis, congue eget ipsum." ]
            ]
        ]
    ]


pageText : Model -> Html Msg
pageText model =
    case model.route of
        HomeRoute ->
            text ("Home - " ++ toString model.changes ++ " changes")

        AboutRoute ->
            text ("About - " ++ toString model.changes ++ " changes")

        NotFoundRoute ->
            text ("Not Found - " ++ toString model.changes ++ " changes")



-- PROGRAM


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
