##  Demo time

Three little animations:

<ul>
<li class="fragment">An "alert" widget
<li class="fragment">An "info box" widget
<li class="fragment">Sliding page transition
</ul>

<a class="fragment" href="http://localhost:8000/page_alert.html">Let's go!</a>

note:
    The Alert widget:
        Is built as an Elm module with reusable view and update functions
        Configuration includes "style" (info, success, etc), dismissal, and HTML content
        Two content areas for summary and details
        Alerts are initially hidden, and do not have a click target that can trigger visibility
        Relies on a small JavaScript port to change visibility
        Content or appearance can be updated programmatically
        Can be dismissed with function call, timeout, page change, or user click
        Can put multiple alerts on an application view, state is maintained in a Dict keyed on each alert's DOM Id
        Alert.update function returns OutMsg so application can monitor transition state


    The InfoBox widget:
        Simpler but shares many features of the Alert widget
        Does have a clickable trigger, so does not need a JavaScript port
