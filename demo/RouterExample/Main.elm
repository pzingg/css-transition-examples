port module RouterExample.Main exposing (main)

{-| RouterExample.Main.elm: A simple single file Elm SPA application demonstrating how to adapt Bootstrap's Carousel component
to demonstrate "router transition" animations in pure Elm and CSS. No JavaScript is required for the animation, but we do
use one JavaScript port that kickstarts the resizing of carousel items just before the CSS transition transform is set.

The application itself is expanded from this example: <https://github.com/sporto/elm-navigation-pushstate>

The host HTML file that loads the JavaScript ports and the required Bootstrap CSS is page_spa.html.

-}

import Array exposing (Array)
import Html exposing (Html, Attribute, div, nav, ul, li, a, h1, h2, h3, h4, p, br, text)
import Html.Attributes exposing (id, class, classList, href, attribute)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Json
import Process
import Task exposing (Task)
import Time exposing (Time)
import Navigation
import UrlParser


-- MODEL


{-| Where we are in the CSS transition. We have to call the `view` function once the route is accepted, but
before the transition is actually started.
-}
type Transition
    = NotStarted
    | RouteAccepted Route
    | InTransition Route
    | TransitionEnded Route


{-| Application state.

  - `changes` is just a counter to show how many times the user has changed the URL. It is just here to prove that we are
    not reloading the page and wiping out the app state.
  - `routes` is an Array of constant size 2, to hold the current route and the (optional) route we are transitioning to.
  - `active` holds the Array index of the current active route
  - `next` holds the Array index of the route we are transitioning to. It is set to `Nothing` initially
    and is reset to `Nothing` after a route transition has been completed.
  - `transition` holds the phase of the CSS transition.

-}
type alias Model =
    { changes : Int
    , routes : Array Route
    , active : Int
    , next : Maybe Int
    , transition : Transition
    }


{-| Accessor function to return the currently active route, or NoRoute if there is no active route
(which should never happen).
-}
activeRoute : Model -> Route
activeRoute model =
    Array.get model.active model.routes
        |> Maybe.withDefault NoRoute


{-| Accessor function to return the route we are transitioning to, or NoRoute if there is no route
to transition to (such as at `init` time).
-}
nextRoute : Model -> Route
nextRoute model =
    model.next
        |> Maybe.andThen
            (\i ->
                Array.get i model.routes
            )
        |> Maybe.withDefault NoRoute



-- MSG


{-| Messages.

  - `ChangeLocation` will be used for initiating a url change
  - `OnLocationChange` will be triggered after a location change
  - `TransitionStart` is triggered to start the animation
  - `TransitionEnd` is triggered by DOM `tranistionend` event

-}
type Msg
    = ChangeLocation String
    | OnLocationChange Navigation.Location
    | TransitionStart Route
    | TransitionEnd Route
    | NoOp



-- INIT


{-| Parse the initial location (or default to `HomeRoute`), and create the `routes` Array and initial
`active` and `next` route pointers.
-}
init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        initialRoute =
            case parseLocation location of
                Nothing ->
                    HomeRoute

                Just NoHashRoute ->
                    HomeRoute

                Just route ->
                    route
    in
        ( { changes = 0
          , routes = Array.fromList [ initialRoute, NoRoute ]
          , active = 0
          , next = Nothing
          , transition = NotStarted
          }
        , Cmd.none
        )



-- ROUTING


{-| These are our available routes.

  - `NotFoundRoute` will be used when we cannot match a route.
  - `NoHashRoute` will be retured from the parser when the `Location.hash` is empty.
  - `NoRoute` is a `Nothing`-like placeholder in the `routes` array when the application is
    initialized or a transition has been completed.

-}
type Route
    = HomeRoute
    | AboutRoute
    | NotFoundRoute
    | NoHashRoute
    | NoRoute


{-| Define how we match hash URLs.
-}
matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [ UrlParser.map HomeRoute UrlParser.top
        , UrlParser.map HomeRoute (UrlParser.s "home")
        , UrlParser.map AboutRoute (UrlParser.s "about")
        ]


{-| Match the `hash` of a Location and return the matched route. If `hash` is the empty string, return `NoHashRoute`,
otherwise let the `UrlParser.parseHash` try to parse the hash.
-}
parseLocation : Navigation.Location -> Maybe Route
parseLocation location =
    case location.hash == "" of
        True ->
            Just NoHashRoute

        False ->
            UrlParser.parseHash matchers location


{-| Create a `Location.hash` string for a given route.
-}
pathForRoute : Route -> Maybe String
pathForRoute route =
    case route of
        HomeRoute ->
            Just homePath

        AboutRoute ->
            Just aboutPath

        _ ->
            Nothing


homePath : String
homePath =
    "#/"


aboutPath : String
aboutPath =
    "#/about"



-- UPDATE


{-| `OnLocationChange` will be called each time the browser location changes. But it also seems to send location
changes with an empty ("") hash component every time the update / view loop executes. So these get parsed into a
`NoHashRoute` that we will ignore.

For any incoming route that is different than the active route, we store the new route in the Model as the `next` route,
and set a timer to send a `TransitionStart` message to start the carousel transition after the carousel items are
set up in the view cycle and are ready for the CSS transitions.

-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeLocation hash ->
            ( model, changeLocation hash )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
                        |> Maybe.withDefault NotFoundRoute

                active =
                    activeRoute model
            in
                case model.transition == NotStarted && newRoute /= NoHashRoute && newRoute /= active of
                    True ->
                        ( { model | changes = model.changes + 1, transition = RouteAccepted newRoute }
                            |> pushNextRoute newRoute
                        , delay (200 * Time.millisecond) (TransitionStart newRoute)
                        )

                    _ ->
                        ( model, Cmd.none )

        TransitionStart route ->
            case route of
                NoRoute ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | transition = InTransition route }
                    , forceReflow ()
                    )

        TransitionEnd route ->
            let
                nextModel =
                    { model | transition = TransitionEnded route }
                        |> makeNextRouteActive
                        |> resetTransition
            in
                ( nextModel
                , activeRoute nextModel
                    |> changeRoute
                )

        NoOp ->
            ( model, Cmd.none )


pushNextRoute : Route -> Model -> Model
pushNextRoute route model =
    let
        ( routes, active, next ) =
            case model.active of
                0 ->
                    ( Array.set 1 route model.routes, 0, Just 1 )

                _ ->
                    ( Array.set 0 route model.routes, 1, Just 0 )
    in
        { model | routes = routes, active = active, next = next }


makeNextRouteActive : Model -> Model
makeNextRouteActive model =
    let
        active =
            case model.next of
                Just n ->
                    n

                Nothing ->
                    model.active
    in
        { model | active = active, next = Nothing }


resetTransition : Model -> Model
resetTransition model =
    { model | transition = NotStarted }


changeRoute : Route -> Cmd Msg
changeRoute route =
    let
        hash =
            pathForRoute route
    in
        case hash of
            Just h ->
                changeLocation h

            Nothing ->
                Cmd.none


changeLocation : String -> Cmd Msg
changeLocation hash =
    Navigation.newUrl hash



-- VIEW


{-| Our view is based on the Bootstrap "Jumbotron" template, with:

    - a navbar
    - a Jumbotron (in which we expose the routes array as an example)
    - a Carousel in which we animate router transitions

-}
view : Model -> Html Msg
view model =
    let
        -- just the real routes, please, in an indexed list
        routes =
            Array.toList model.routes
                |> List.filter (\r -> r /= NoRoute)
                |> List.indexedMap (,)

        -- use the carouselItem function to generate the carousel items
        carouselItems =
            routes
                |> List.map (\( i, route ) -> ( i, carouselItem route model ))

        infos =
            routes
                |> List.map (\( i, route ) -> pageInfo i route model)

        singleton =
            model.next == Nothing

        ( buttonText, buttonMsg ) =
            case ( singleton, model.transition ) of
                ( False, RouteAccepted transNext ) ->
                    ( "Start Transition", TransitionStart transNext )

                _ ->
                    ( "Nothing to do", NoOp )
    in
        div [ class "container" ]
            [ div
                [ class "header clearfix" ]
                [ navbar model
                , h3
                    [ class "text-muted" ]
                    [ text "CSS Transitions in Elm" ]
                ]
            , div [ class "jumbotron" ]
                (List.concat
                    [ [ h1 [] [ pageText (activeRoute model) model.changes ] ]
                    , infos
                    , [ p []
                            [ a
                                [ class "btn btn-lg btn-success"
                                , href "#"
                                , attribute "role" "button"
                                , onClick buttonMsg
                                ]
                                [ text buttonText ]
                            ]
                      ]
                    ]
                )
            , carousel carouselItems
            ]


{-| We want our links to show a proper href e.g. "/about", so we include an href attribute.
onLinkClick will prevent the browser reloading the page.
-}
navbar : Model -> Html Msg
navbar model =
    let
        active =
            activeRoute model
    in
        nav []
            [ ul [ class "nav nav-pills pull-right" ]
                [ li [ classList [ ( "active", active == HomeRoute ) ], attribute "role" "presentation" ]
                    [ a [ href homePath, onLinkClick (ChangeLocation homePath) ]
                        [ text "Home" ]
                    ]
                , li [ classList [ ( "active", active == AboutRoute ) ], attribute "role" "presentation" ]
                    [ a [ href aboutPath, onLinkClick (ChangeLocation aboutPath) ]
                        [ text "About" ]
                    ]
                , li [ classList [ ( "active", False ) ], attribute "role" "presentation" ]
                    [ a [ href "#" ]
                        [ text "Contact" ]
                    ]
                ]
            ]


{-| When clicking a link we want to prevent the default browser behaviour which is to load a new page.
So we use `onWithOptions` instead of `onClick`.
-}
onLinkClick : msg -> Attribute msg
onLinkClick message =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }
    in
        onWithOptions "click" options (Json.succeed message)


{-| Generate the HTML for a Bootstrap Carousel container. `carouselItems` is an indexed list of the content
that will be displayed for each carousel item.
-}
carousel : List ( Int, Html Msg ) -> Html Msg
carousel carouselItems =
    div [ class "carousel slide", attribute "data-ride" "carousel", id "page-carousel" ]
        [ div [ class "carousel-inner" ]
            (List.map Tuple.second carouselItems)
        ]


{-| Sample Bootstrap Carousel `item` page generated for a route.
-}
carouselItem : Route -> Model -> Html Msg
carouselItem route model =
    div
        [ class <| carouselItemClasses route model
        , onWithOptions "transitionend"
            { stopPropagation = True, preventDefault = True }
            (Json.succeed <| TransitionEnd (nextRoute model))
        ]
        [ div
            [ class "container" ]
            [ div
                [ class "row" ]
                (pageContent route model.changes)
            ]
        ]


{-| Sample content for a page. Obviously a real application would have different `page` functions for each route.
-}
pageContent : Route -> Int -> List (Html Msg)
pageContent route changes =
    [ h4 []
        [ pageText route changes ]
    , p []
        [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet tellus tincidunt, auctor orci quis, porttitor ex. Sed sed varius magna, in mollis mauris. Nullam pharetra lacus justo, sed placerat est elementum sit amet. Aliquam fermentum eu est eu ullamcorper. Sed magna eros, dictum eget ligula vel, pellentesque blandit eros. Aenean euismod ante in aliquet cursus. Pellentesque et ultricies libero. Duis malesuada velit quam, sed pharetra ipsum volutpat nec. Donec eu mauris eros. In hac habitasse platea dictumst. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Fusce molestie, nibh id semper pretium, velit tellus pellentesque mauris, nec bibendum erat diam quis ligula. In volutpat elementum vulputate. Morbi rutrum enim nisi, sit amet faucibus urna facilisis sit amet. Praesent tortor libero, hendrerit vel vulputate ac, sagittis sit amet quam. Etiam ligula justo, semper in risus non, elementum scelerisque sem." ]
    ]


{-| Sample text generated for a page.
-}
pageText : Route -> Int -> Html Msg
pageText route changes =
    case route of
        HomeRoute ->
            text ("Home - " ++ toString changes ++ " changes")

        AboutRoute ->
            text ("About - " ++ toString changes ++ " changes")

        NotFoundRoute ->
            text ("Not Found - " ++ toString changes ++ " changes")

        NoHashRoute ->
            text ("No Hash - " ++ toString changes ++ " changes")

        NoRoute ->
            text ("No Previous - " ++ toString changes ++ " changes")


{-| Sample text generated for the "jumbotron". We just show the state of the carousel items.
-}
pageInfo : Int -> Route -> Model -> Html Msg
pageInfo i route model =
    div []
        [ p []
            [ text ("Item " ++ toString i)
            , br [] []
            , text ("Route " ++ toString route)
            , br [] []
            , text ("Classes " ++ carouselItemClasses route model)
            ]
        ]


{-| Calculate the DOM classes for a carousel item, based on the tranistion state and whether the route is
the current "active" route (the route the application is transitioning from), or the "next" route
(the route the application is transitioning to), or the case where there is no "next" route (after the
transition is finished).
-}
carouselItemClasses : Route -> Model -> String
carouselItemClasses route model =
    let
        singleton =
            model.next == Nothing

        ( active, next, direction ) =
            case ( singleton, model.transition ) of
                ( False, RouteAccepted transNext ) ->
                    ( route == activeRoute model, route == transNext, False )

                ( False, InTransition transNext ) ->
                    ( route == activeRoute model, route == transNext, True )

                ( False, TransitionEnded transNext ) ->
                    ( route == transNext, route == activeRoute model, False )

                _ ->
                    ( route == activeRoute model, False, False )

        -- Borrowed from Html.classList.
        -- Given a list of tuples of ( String, Bool ), join the strings for which the boolean is True.
        itemClasses list =
            list
                |> List.filter Tuple.second
                |> List.map Tuple.first
                |> String.join " "
    in
        itemClasses
            [ ( "item spa-page-item", True )
            , ( "active", active )
            , ( "next", next )
            , ( "left", direction )
            ]


{-| Send a message some time in the future.
-}
delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


{-| In bootstap.js, the "next" item makes a call to offsetWidth to force a reflow?
-}
port forceReflow : () -> Cmd msg



-- PROGRAM


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
