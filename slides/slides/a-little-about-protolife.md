##  A little about ProtoLife

<img alt="ProtoLife PDT UI" src="resources/PDT-ESD.png" style="border: none; width: 750px;">

note:
* A web interface for the optimization of high-throughput scientific experiments, typically found in biotech,
materials development, and process design.
* Target customer is individual scientist.
* What's interesting about our technology is that it is about "small data" rather than "big data".
* Rather than trying to gather massive data sets that can be analyzed offline for classification,
each scientific project has a relatively small set of variables and and a single outcome.
* We use a number of techniques to identify optimal inputs for each subsequent generation of experiments.
* Some of the bits I enjoyed coding in Elm for this project (besides the CSS animations):
    * Extending the Handsontable Polymer web component with more DOM CustomEvents so Elm can listen for them
    * Using Html.Keyed to manage web component lifecycles when Elm and Polymer don't always play well together
    * Using Cmd and Sub ports to handle the Shiny Server message API
    * Learning how to code a native module and create an Http-like Request and Task system
