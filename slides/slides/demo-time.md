##  Demo time

Three little animations:

<ul>
<li class="fragment">An "info box" widget - <code>transition: height</code>
<li class="fragment">An "alert" widget - <code>transition: height</code>
<li class="fragment">Page transition carousel - <code>transition: transform</code>
</ul>

<a class="fragment" href="../../demo/">Let's go!</a>

note:
The info box widget:
* Is built as an Elm module with reusable view and update functions
* Can put multiple widgets on an application view, state is maintained in a Dict keyed on each
widget's DOM Id
* Widget opens and closes via a click event on the question mark icon
* Height of widget content determined dynamically via a JSON decoder that responds to the
click event
* Module's update function returns OutMsg so application can monitor transition state

The alert widget:
* More complex, but shares many features of the info box widget
* Two content areas for summary and details
* Alerts are initially hidden, and do not have a click target that can trigger visibility, so
we rely on a small JavaScript port to dispatch a custom DOM event to open the alert
* Configuration includes "style" (info, success, etc), dismissal, and HTML content
* Content or appearance can be updated programmatically
* Can be dismissed with function call, timeout, page change, or user click

The page transition example:
* Uses Bootstrap carousel CSS styles that involve CSS transitions on the transform property
* Applying DOM classes to carousel items set the initial and target transform values
