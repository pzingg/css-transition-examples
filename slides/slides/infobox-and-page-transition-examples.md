##  Behind the InfoBox and Page Transition demos

<pre class="fragment"><code class="elm">iconClickHandler : String -> Decoder Msg
iconClickHandler domId =
    wellHeightDecoder
        |> Json.andThen (\height ->
            Json.succeed <| IconClicked domId height)
</code></pre>

<pre class="fragment"><code class="elm">carouselItemHelper : Route -> Model -> ( Bool, Bool, Bool )
carouselItemHelper route model =
    case ( model.next == Nothing, model.transition ) of
        ( False, RouteAccepted nextRoute ) ->
            ( route == activeRoute model, route == nextRoute, False )

        ( False, InTransition nextRoute ) ->
            ( route == activeRoute model, route == nextRoute, True )

        ( False, TransitionEnded nextRoute ) ->
            ( route == nextRoute, route == activeRoute model, False )

        _ ->
            ( route == activeRoute model, False, False )
</code></pre>


note:
* The code for the InfoBox example is very similar to the alert. Here you can see the click handler
wired to the height decoder.
* The page transition example manipulates DOM classes in a particular sequence, so that the
CSS styles set up by Bootstrap's carousel component will create the proper initial and target transform
properties to effect the animation.
* Here's an example update helper function from the page transition example
that returns a triple indicating whether the particular carousel item should have the
"active", "next", and/or "left" DOM classes applied, depending on the
state of the transition and whether a next route has been set up.
* All the code for these three demos is in the repository
