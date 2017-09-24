##  Handling the `Resized` message<br>in the `Alert.update` function

<pre><code class="elm" data-trim data-noescape>resized : String -> Float -> Float -> State -> ( State, Properties )
resized domId sHeight dHeight state =
    let
        ( nextState, props ) =
            mapProperties domId (\props ->
                case props.visibility of
                    <mark>Opening -></mark>
                        <mark>{ props</mark>
                            <mark>| visibility = Summary</mark>
                            <mark>, summaryHeight = sHeight</mark>
                            <mark>, detailsHeight = dHeight</mark>
                        <mark>}</mark>
                    ...
            ) state
    in
        ( nextState, props )
</code></pre>

note:
* Here's the code that handles that `Resized` message in our `Alert.update` function.
* We use a helper function `resized` that will update the properties of our alert model
and change the state from `Opening` to `Summary`, so our `view` function will
then set the target height of the animation and we'll be off and animating.
