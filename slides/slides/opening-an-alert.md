##  Opening an alert

<pre><code class="elm" data-trim data-noescape>open : Config -> State -> ( State, Cmd msg )
open { domId, dismissal } ((State priv) as state) =
    let
        let
            instanceId =
                priv.currentId + 1

        ( nextState, _ ) =
            mapProperties domId
                (\props ->
                    <mark>{ props</mark>
                        <mark>| instanceId = instanceId</mark>
                        <mark>, dismissal = dismissal</mark>
                        <mark>, visibility = Opening</mark>
                        <mark>, summaryHeight = 0</mark>
                        <mark>, detailsHeight = 0</mark>
                    }
                )
                (State { priv | currentId = instanceId })
    in
        ( nextState, <mark>openAlertNextFrame domId</mark> )
</code></pre>

note:
Here's where we call the `openAlertNextFrame`, after we have set the properties of the alert
to the `Opening` visibility state.
