##  Using a `Process.sleep` Task

<pre><code class="elm" data-trim data-noescape>{-| Use Process.sleep Task to send a message some time in the future.
-}
delay : Time -> msg -> Cmd msg
delay time msg =
    Process.sleep time
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity
</code></pre>

<pre class="fragment"><code class="elm" data-trim data-noescape>delay (100 * Time.millisecond) (TransitionStart newRoute)
</code></pre>


note:
* Here's how to create a Task that will send a message some time in the future.
* And here's an example from the page transition demo that starts the transition after 100 milliseconds, enough time
for the initial state to be rendered on the VDOM.
* (I don't recommend this technique, but it seems to work!)
