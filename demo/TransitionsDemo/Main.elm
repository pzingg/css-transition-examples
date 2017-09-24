port module TransitionsDemo.Main exposing (main)

{-| The application is a simple Elm SPA demonstrating three different CSS transition user
interfaces:

1.  Alert widget that is initially closed, but opens with animation when called programmatically.
2.  Info box widget that expands when an element is clicked.
3.  A router transition effect, adapted from Bootstrap's Carousel component, that slides page
    content in from the right when the active route is changed.

No JavaScript is required for the animations themselves, but we do use some JavaScript ports:

1.  When we want to open an alert, we call a port that dispatches a custom DOM event so that we can
    find out the height of the content we'll be expanding.
2.  Before we start the router transition animation, we call a port that gets the offsetWidth of
    the content that will be animated directly.

The application itself is expanded from this example: <https://github.com/sporto/elm-navigation-pushstate>

The host HTML file that loads the JavaScript ports and the required Bootstrap CSS is index.html.

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
import TransitionsDemo.Quotes as Quotes


-- MODEL


{-| Application state.

  - `alerts` is the opaque state of all alerts in the application (see the Alert module for more
    information).
  - `alertConfigIndex` just holds an integer to cycle through the different alert types.
  - `infoBoxes` is the opaque state of all info boexs in the application (see the InfoBox module
    for more information).
  - `routes` is an Array of constant size 2, to hold the current route and the (optional) route
    we are transitioning to.
  - `activeRouteIndex` holds the Array index of the current active route
  - `nextRouteIndex` holds the Array index of the route we are transitioning to. It is set to
    `Nothing` initially and is reset to `Nothing` after a route transition has been completed.
  - `routerTansition` holds the phase of the CSS transition.
  - `pages` is a parallel Array to `routes`. Each member of the Array holds a quote.
  - `quotes` is our random quote generation system.

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
    , routerTransition : RouterTransition

    -- content
    , pages : Array Page
    , quotes : Quotes.Model
    }


{-| In a real application the page content would be dynamically created, here we just use a pair
of Strings from a quotation database as the content.
-}
type alias Page =
    Quotes.Quote


{-| Where we are in the CSS router transition. We have to call the `view` function once the route
is accepted, but before the transition is actually started.
-}
type RouterTransition
    = NotStarted
    | RouteAccepted Route
    | InTransition Route
    | TransitionEnded Route



-- MSG


{-| Messages.

Messages for manipulating alerts:

  - `ShowAlert` will be used to show one of the four example alert configurations
  - `DismissAlert` will be used to dismiss that configurations
  - `AlertMsg` is a sub-message to be dispatched to the Alert module's `update` function

Messages for manipulating info boxes:

  - `InfoBoxMsg` is a sub-message to be dispatched to the InfoBox module's `update` function

Messages for handling SPA navigation and animating the router transitions:

  - `ChangeLocation` will be used for initiating a url change
  - `OnLocationChange` will be triggered after a location change
  - `RouterTransitionStart` is triggered to start the animation
  - `RouterTransitionEnd` is triggered by DOM `tranistionend` event

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
    | RouterTransitionStart Route
    | RouterTransitionEnd Route



-- INIT


{-| Flags passed into our application from JavaScript at startup. We import a random number
seed for the random quote generator.
-}
type alias Flags =
    { randSeed : Int }


{-| Parse the initial location (or default to `HomeRoute`), and create the `routes` Array and
initial `active` and `next` route pointers.
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



-- UPDATE


{-| `OnLocationChange` will be called each time the browser location changes. But it also seems to send location
changes with an empty ("") hash component every time the update / view loop executes. So these get parsed into a
`NoHashRoute` that we will ignore.

For any incoming route that is different than the active route, we store the new route in the Model as the `next` route,
and set a timer to send a `RouterTransitionStart` message to start the carousel transition after the carousel items are
set up in the view cycle and are ready for the CSS transitions.

-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Alert UI messages
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

        -- Alert sub-messages
        -- Just pass them to the Alert.update function
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

        -- Info box sub-messages
        -- Just pass them to the InfoBox.update function
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

        -- Navigation messages
        -- Change the browser history when location changes.
        ChangeLocation hash ->
            ( model, changeLocation hash )

        -- When location was changed, see if we can navigate to new route.
        -- If valid, change to a new page on that route.
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
                        |> Maybe.withDefault NotFoundRoute
            in
                case
                    (model.routerTransition == NotStarted)
                        && (newRoute /= NoHashRoute)
                        && (newRoute /= getActiveRoute model)
                of
                    True ->
                        pageChange newRoute model

                    _ ->
                        ( model, Cmd.none )

        -- Router transition messages
        RouterTransitionStart route ->
            case route of
                NoRoute ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | routerTransition = InTransition route }
                    , forceReflow ()
                    )

        RouterTransitionEnd route ->
            let
                nextModel =
                    { model | routerTransition = TransitionEnded route }
                        |> makeNextRouteActive
                        |> resetTransition
            in
                ( nextModel, changeLocationToActiveRoute nextModel )

        NoOp ->
            ( model, Cmd.none )



-- ROUTING TRANSITION HELPERS


{-| Update the browser history when a new location URL is received.
-}
changeLocation : String -> Cmd msg
changeLocation hash =
    Navigation.newUrl hash


{-| After transition is ended, update the browser history to the new active route.
-}
changeLocationToActiveRoute : Model -> Cmd msg
changeLocationToActiveRoute model =
    case getActiveRoute model |> pathForRoute of
        Just hash ->
            changeLocation hash

        Nothing ->
            Cmd.none


{-| We are change pages. Dismiss any alerts, start the rotuer transition, generate
some new content, and then call pushNextRoute to set up the routes and pages
arrays.
-}
pageChange : Route -> Model -> ( Model, Cmd Msg )
pageChange newRoute model =
    ( { model
        | alerts = Alert.pageChangeDismiss model.alerts
        , routerTransition = RouteAccepted newRoute
        , quotes = Quotes.next model.quotes
      }
        |> pushNextRoute newRoute
    , delay (200 * Time.millisecond) (RouterTransitionStart newRoute)
    )


{-| The active route and next route, and the content for the corresponding active and next pages,
are kept in arrays of size 2. Load the next route and its page content into the currently inactive
slot in the respective arrays.
-}
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


{-| After the router transition is done, we switch the active route to what was the next route,
and set the nextRouteIndex to Nothing (meaning we only have one route again).
-}
makeNextRouteActive : Model -> Model
makeNextRouteActive model =
    let
        activeIndex =
            model.nextRouteIndex
                |> Maybe.withDefault model.activeRouteIndex
    in
        { model | activeRouteIndex = activeIndex, nextRouteIndex = Nothing }


{-| Set transition back to starting point.
-}
resetTransition : Model -> Model
resetTransition model =
    { model | routerTransition = NotStarted }



-- VIEW


{-| Four different example alert configurations, with different severities, dismissal types, etc.
Note that we are using the same `domId` for all four configurations, so each configuration
will overwrite the previous one when `openAlert` is called.
-}
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
            , dismissal = DismissOnPageChange
            , summary = "This informational alert should vanish on page change!"
            , details = Just "And you expanded the details content. Double hurray!"
            }


{-| Example configuration for an info box. The `domId` will be separate for each route,
so the states will be independent on each page.
-}
infoBoxConfig : Route -> InfoBox.Config
infoBoxConfig route =
    { domId = "ib-" ++ toString route
    , tagName = "p"
    , htext = "Is this quotation in the public domain"
    , content =
        div []
            [ p [] [ text "For works published or registered before 1978, the maximum copyright duration is 95 years from the date of publication, if copyright was renewed during the 28th year following publication. Copyright renewal has been automatic since the Copyright Renewal Act of 1992." ]
            , p [] [ text "In May 2016, Judge Percy Anderson ruled in a lawsuit between ABS Entertainment and CBS Radio that \"remastered\" versions of pre-1972 recordings can receive a federal copyright as a distinct work due to the amount of creative effort expressed in the process." ]
            , p []
                [ text "Source: "
                , a [ href "https://en.wikipedia.org/wiki/Copyright_law_of_the_United_States" ] [ text "Wikipedia" ]
                ]
            ]
    }


{-| Our view is based on a Bootstrap template, with:

    - a navbar.
    - an alert (initially hidden).
    - a Bootstrap carousel in which we animate router transitions. Each carousel item holds
    page content, including an info box.

-}
view : Model -> Html Msg
view model =
    let
        -- Fetch just the real routes as an indexed list
        routes =
            Array.toList model.routes
                |> List.filter (\r -> r /= NoRoute)
                |> List.indexedMap (,)

        -- Use the carouselItem function to generate the content for the carousel items
        carouselItems =
            routes
                |> List.map (\( i, route ) -> (carouselItem i route model))
    in
        -- Assemble the navbar, alert and carousel
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
                    [ a [ href "../slides/dist/#/post-demo" ]
                        [ text "Back to Slides" ]
                    ]
                ]
            ]


noBubble : Html.Events.Options
noBubble =
    { stopPropagation = True, preventDefault = True }


noDefault : Html.Events.Options
noDefault =
    { stopPropagation = False, preventDefault = True }


{-| When clicking a link we want to prevent the default browser behaviour which is to load a
new page. So we use `onWithOptions` instead of `onClick`.
-}
onLinkClick : msg -> Attribute msg
onLinkClick message =
    onWithOptions "click" noDefault <| Json.succeed message


{-| Generate the HTML for a Bootstrap Carousel container. `carouselItems` is an indexed list
of the content that will be displayed for each carousel item.
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
            , onWithOptions "transitionend" noBubble <|
                Json.succeed <|
                    RouterTransitionEnd (getNextRoute model)
            ]
            [ div [ class "row" ]
                [ div [ class "col-lg-12" ] content ]
            ]


{-| Sample content for a page. Obviously a real application would have different `page`
functions for each route.
-}
getPageContent : Int -> Route -> Model -> List (Html Msg)
getPageContent i route model =
    [ pageHeader route
    , pageQuote i model
    , InfoBox.view (infoBoxConfig route) model.infoBoxes
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


{-| Sample header text generated for a page.
-}
pageHeader : Route -> Html Msg
pageHeader route =
    let
        txt =
            case route of
                HomeRoute ->
                    "Home Page"

                AboutRoute ->
                    "About Page"

                NotFoundRoute ->
                    "Page Not Found"

                NoHashRoute ->
                    "ERROR! No Hash"

                NoRoute ->
                    "ERROR! No Previous Route"
    in
        h2 []
            [ text txt ]


{-| Sample content generated for a page.
-}
pageQuote : Int -> Model -> Html Msg
pageQuote i model =
    let
        quote =
            Array.get i model.pages
                |> Maybe.withDefault Quotes.errorQuote
    in
        div []
            [ p [ style [ ( "font-size", "1.5em" ) ] ]
                [ text quote.quoteText ]
            , p [ style [ ( "font-style", "italic" ) ] ]
                -- emdash
                [ text ("— " ++ quote.quoteAuthor) ]
            ]


{-| Determine the whether the class name applied to the carousel item for the specified route
will be "active", "next", and/or "left", based on the transition state and whether the
route is the current "active" route (the route the application is transitioning from), or the
"next" route (the route the application is transitioning to), or in the case where there is no
"next" route (after the transition is finished).
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


{-| Calculate the DOM class names for a carousel item, using the helper function.
-}
carouselItemClasses : Route -> Model -> String
carouselItemClasses route model =
    let
        ( isActive, isNext, isLeft ) =
            carouselItemHelper route model

        -- Borrowed from Html.classList:  Given a list of tuples of ( String, Bool ),
        -- join the strings for which the predicate is True.
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
