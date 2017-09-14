port module RouterExample.Main exposing (main)

{-| RouterExample.Main.elm: A simple single file Elm SPA application demonstrating how to adapt Bootstrap's Carousel component
to demonstrate "router transition" animations in pure Elm and CSS. No JavaScript is required for the animation, but we do
use one JavaScript port that kickstarts the resizing of carousel items just before the CSS transition transform is set.

The application itself is expanded from this example: <https://github.com/sporto/elm-navigation-pushstate>

The host HTML file that loads the JavaScript ports and the required Bootstrap CSS is page_spa.html.

-}

import Array exposing (Array)
import Html exposing (Html, Attribute, div, nav, ul, li, a, h1, h2, h3, h4, p, br, text)
import Html.Attributes exposing (id, class, classList, href, style, attribute)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Json
import Process
import Task exposing (Task)
import Time exposing (Time)
import Navigation
import UrlParser
import Alert exposing (..)
import InfoBox
import RouterExample.Quotes as Quotes


-- MODEL


{-| Where we are in the CSS transition. We have to call the `view` function once the route is accepted, but
before the transition is actually started.
-}
type Transition
    = NotStarted
    | RouteAccepted Route
    | InTransition Route
    | TransitionEnded Route


type alias Page =
    Quotes.Quote


{-| Application state.

  - `routes` is an Array of constant size 2, to hold the current route and the (optional) route we are transitioning to.
  - `activeRouteIndex` holds the Array index of the current active route
  - `nextRouteIndex` holds the Array index of the route we are transitioning to. It is set to `Nothing` initially
    and is reset to `Nothing` after a route transition has been completed.
  - `routerTansition` holds the phase of the CSS transition.

-}
type alias Model =
    { -- alert state
      alerts : Alert.State
    , alertConfigIndex : Int

    -- info box state
    , infoBoxes : InfoBox.State

    -- route state
    , routes : Array Route
    , activeRouteIndex : Int
    , nextRouteIndex : Maybe Int
    , routerTransition : Transition

    -- content
    , pages : Array Page
    , quotes : Quotes.Model
    }


{-| Accessor function to return the currently active route, or NoRoute if there is no active route
(which should never happen).
-}
getActiveRoute : Model -> Route
getActiveRoute model =
    Array.get model.activeRouteIndex model.routes
        |> Maybe.withDefault NoRoute


{-| Accessor function to return the route we are transitioning to, or NoRoute if there is no route
to transition to (such as at `init` time).
-}
getNextRoute : Model -> Route
getNextRoute model =
    model.nextRouteIndex
        |> Maybe.andThen
            (\i ->
                Array.get i model.routes
            )
        |> Maybe.withDefault NoRoute


{-| Accessor function that returns True if only the active route is loaded into the routes array.
-}
noNextRoute : Model -> Bool
noNextRoute model =
    model.nextRouteIndex == Nothing



-- MSG


{-| Messages.

  - `ChangeLocation` will be used for initiating a url change
  - `OnLocationChange` will be triggered after a location change
  - `TransitionStart` is triggered to start the animation
  - `TransitionEnd` is triggered by DOM `tranistionend` event

-}
type Msg
    = NoOp
      -- alert messages
    | ShowAlert Int
    | DismissAlert Int
    | AlertMsg Alert.Msg
      -- info box messages
    | InfoBoxMsg InfoBox.Msg
      -- router transition messages
    | ChangeLocation String
    | OnLocationChange Navigation.Location
    | TransitionStart Route
    | TransitionEnd Route



-- INIT


{-| Flags passed into our application from JavaScript at startup
-}
type alias Flags =
    { randSeed : Int }


{-| Parse the initial location (or default to `HomeRoute`), and create the `routes` Array and initial
`active` and `next` route pointers.
-}
init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        initialRoute =
            case parseLocation location of
                Nothing ->
                    HomeRoute

                Just NoHashRoute ->
                    HomeRoute

                Just route ->
                    route

        quotes =
            Quotes.init <| Debug.log "randSeed" flags.randSeed

        initialPage =
            Quotes.get quotes
    in
        ( { alerts = Alert.init
          , alertConfigIndex = 0
          , infoBoxes = InfoBox.init
          , routes = Array.fromList [ initialRoute, NoRoute ]
          , activeRouteIndex = 0
          , nextRouteIndex = Nothing
          , routerTransition = NotStarted
          , pages = Array.fromList [ initialPage, Quotes.errorQuote ]
          , quotes = quotes
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
        -- alert messages
        ShowAlert i ->
            let
                config =
                    alertConfig i

                ( nextState, alertCmd ) =
                    Alert.open config model.alerts
            in
                ( { model | alerts = nextState, alertConfigIndex = i }, alertCmd )

        DismissAlert i ->
            let
                config =
                    alertConfig i

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

        -- info box messages
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

        -- router transition messages
        ChangeLocation hash ->
            ( model, changeLocation hash )

        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
                        |> Maybe.withDefault NotFoundRoute

                activeRoute =
                    getActiveRoute model
            in
                case model.routerTransition == NotStarted && newRoute /= NoHashRoute && newRoute /= activeRoute of
                    True ->
                        ( { model | routerTransition = RouteAccepted newRoute, quotes = Quotes.next model.quotes }
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
                    ( { model | routerTransition = InTransition route }
                    , forceReflow ()
                    )

        TransitionEnd route ->
            let
                nextModel =
                    { model | routerTransition = TransitionEnded route }
                        |> makeNextRouteActive
                        |> resetTransition
            in
                ( nextModel
                , getActiveRoute nextModel
                    |> changeRoute
                )

        NoOp ->
            ( model, Cmd.none )


pushNextRoute : Route -> Model -> Model
pushNextRoute route model =
    let
        ( activeIndex, nextIndex ) =
            case model.activeRouteIndex of
                0 ->
                    ( 0, 1 )

                _ ->
                    ( 1, 0 )

        nextQuotes =
            Quotes.next model.quotes

        nextPage =
            Quotes.get nextQuotes
    in
        { model
            | routes = Array.set nextIndex route model.routes
            , activeRouteIndex = activeIndex
            , nextRouteIndex = Just nextIndex
            , pages = Array.set nextIndex nextPage model.pages
        }


makeNextRouteActive : Model -> Model
makeNextRouteActive model =
    let
        activeIndex =
            model.nextRouteIndex
                |> Maybe.withDefault model.activeRouteIndex
    in
        { model | activeRouteIndex = activeIndex, nextRouteIndex = Nothing }


resetTransition : Model -> Model
resetTransition model =
    { model | routerTransition = NotStarted }


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


alertConfig : Int -> Alert.Config
alertConfig i =
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


infoBoxConfig : InfoBox.Config
infoBoxConfig =
    { domId = "ib-example"
    , tagName = "p"
    , htext = "Is this quotation in the public domain"
    , content =
        div []
            [ p [] [ text "For works published or registered before 1978, the maximum copyright duration is 95 years from the date of publication, if copyright was renewed during the 28th year following publication. Copyright renewal has been automatic since the Copyright Renewal Act of 1992." ]
            , p [] [ text "For works created before 1978, but not published or registered before 1978, the standard §302 copyright duration also applies. Prior to 1978, works had to be published or registered to receive copyright protection. Upon the effective date of the 1976 Copyright Act (which was January 1, 1978) this requirement was removed and these unpublished, unregistered works received protection. However, Congress intended to provide an incentive for these authors to publish their unpublished works. To provide that incentive, these works, if published before 2003, would not have their protection expire before 2048." ]
            , p [] [ text "All copyrightable works published in the United States before 1923 are in the public domain; works created before 1978 but not published until recently may be protected until 2047. For works that received their copyright before 1978, a renewal had to be filed in the work's 28th year with the Copyright Office for its term of protection to be extended. The need for renewal was eliminated by the Copyright Renewal Act of 1992, but works that had already entered the public domain by non-renewal did not regain copyright protection. Therefore, works published before 1964 that were not renewed are in the public domain." ]
            , p [] [ text "Before 1972, sound recordings were not subject to federal copyright, but copying was nonetheless regulated under various state torts and statutes, some of which had no duration limit. The Sound Recording Amendment of 1971 extended federal copyright to recordings fixed on or after February 15, 1972, and declared that recordings fixed before that date would remain subject to state or common law copyright. Subsequent amendments have extended this latter provision until 2067. As a result, older sound recordings are not subject to the expiration rules that apply to contemporary visual works. Although these may enter the public domain as a result of government authorship or formal grant by the owner, the practical effect has been to render public domain audio virtually nonexistent." ]
            , p [] [ text "In May 2016, Judge Percy Anderson ruled in a lawsuit between ABS Entertainment and CBS Radio that \"remastered\" versions of pre-1972 recordings can receive a federal copyright as a distinct work due to the amount of creative effort expressed in the process." ]
            , p []
                [ text "Source: "
                , a [ href "https://en.wikipedia.org/wiki/Copyright_law_of_the_United_States" ] [ text "Wikipedia" ]
                ]
            ]
    }


{-| Our view is based on the Bootstrap "Jumbotron" template, with:

    - a navbar
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
                |> List.map (\( i, route ) -> (carouselItem i route model))
    in
        div [ class "container" ]
            [ div
                [ class "header clearfix" ]
                [ navbar model
                , h3
                    [ class "text-muted" ]
                    [ text "CSS Transitions in Elm" ]
                ]
            , Alert.view (alertConfig model.alertConfigIndex) model.alerts
                |> Html.map AlertMsg
            , carousel carouselItems
            ]


{-| We want our links to show a proper href e.g. "/about", so we include an href attribute.
onLinkClick will prevent the browser reloading the page.
-}
navbar : Model -> Html Msg
navbar model =
    let
        activeRoute =
            getActiveRoute model
    in
        nav []
            [ ul [ class "nav nav-pills pull-right" ]
                [ li [ classList [ ( "active", activeRoute == HomeRoute ) ], attribute "role" "presentation" ]
                    [ a [ href homePath, onLinkClick (ChangeLocation homePath) ]
                        [ text "Home" ]
                    ]
                , li [ classList [ ( "active", activeRoute == AboutRoute ) ], attribute "role" "presentation" ]
                    [ a [ href aboutPath, onLinkClick (ChangeLocation aboutPath) ]
                        [ text "About" ]
                    ]
                , li [ attribute "role" "presentation" ]
                    [ a [ href "http://localhost:9000/#/9" ]
                        [ text "Back to Slides" ]
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
carousel : List (Html Msg) -> Html Msg
carousel carouselItems =
    div [ class "carousel slide", attribute "data-ride" "carousel", id "page-carousel" ]
        [ div [ class "carousel-inner" ] carouselItems ]


{-| Sample Bootstrap Carousel `item` page generated for a route.
-}
carouselItem : Int -> Route -> Model -> Html Msg
carouselItem i route model =
    let
        content =
            getPageContent i route model
    in
        div
            [ class <| carouselItemClasses route model
            , onWithOptions "transitionend"
                { stopPropagation = True, preventDefault = True }
                (Json.succeed <| TransitionEnd (getNextRoute model))
            ]
            [ div [ class "row" ]
                [ div [ class "col-lg-12" ] content ]
            ]


{-| Sample content for a page. Obviously a real application would have different `page` functions for each route.
-}
getPageContent : Int -> Route -> Model -> List (Html Msg)
getPageContent i route model =
    let
        quote =
            Array.get i model.pages
                |> Maybe.withDefault Quotes.errorQuote
    in
        [ h2 []
            [ pageText route ]
        , p [ style [ ( "font-size", "1.5em" ) ] ]
            [ text quote.quoteText ]
        , p [ style [ ( "font-style", "italic" ) ] ]
            -- emdash
            [ text ("— " ++ quote.quoteAuthor) ]
        , InfoBox.view infoBoxConfig model.infoBoxes
            |> Html.map InfoBoxMsg
        , p []
            [ a
                [ class "btn btn-lg btn-success"
                , href "#"
                , attribute "role" "button"
                , onClick <| ShowAlert (model.alertConfigIndex + 1)
                ]
                [ text "Next Alert" ]
            , a
                [ class "btn btn-lg btn-info"
                , style [ ( "margin-left", "10px" ) ]
                , href "#"
                , attribute "role" "button"
                , onClick <| DismissAlert model.alertConfigIndex
                ]
                [ text "Dismiss Alert" ]
            ]
        ]


{-| Sample text generated for a page.
-}
pageText : Route -> Html Msg
pageText route =
    case route of
        HomeRoute ->
            text "Home Page"

        AboutRoute ->
            text "About Page"

        NotFoundRoute ->
            text "Page Not Found"

        NoHashRoute ->
            text "ERROR! No Hash"

        NoRoute ->
            text "ERROR! No Previous Route"


{-| Determine the whether the class name applied to the carousel item for the
specified route will be "active", "next", and/or "left", depending on the transition state.
-}
carouselItemHelper : Route -> Model -> ( Bool, Bool, Bool )
carouselItemHelper route model =
    let
        activeRoute =
            getActiveRoute model
    in
        case ( noNextRoute model, model.routerTransition ) of
            ( False, RouteAccepted nextRoute ) ->
                ( route == activeRoute, route == nextRoute, False )

            ( False, InTransition nextRoute ) ->
                ( route == activeRoute, route == nextRoute, True )

            ( False, TransitionEnded nextRoute ) ->
                ( route == nextRoute, route == activeRoute, False )

            _ ->
                ( route == activeRoute, False, False )


{-| Calculate the DOM classes for a carousel item, based on the tranistion state and whether the route is
the current "active" route (the route the application is transitioning from), or the "next" route
(the route the application is transitioning to), or the case where there is no "next" route (after the
transition is finished).
-}
carouselItemClasses : Route -> Model -> String
carouselItemClasses route model =
    let
        ( isActive, isNext, isLeft ) =
            carouselItemHelper route model

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
            , ( "active", isActive )
            , ( "next", isNext )
            , ( "left", isLeft )
            ]


{-| Use Process.sleep Task to send a message some time in the future.
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


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
