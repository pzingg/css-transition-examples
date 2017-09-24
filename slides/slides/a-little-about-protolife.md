##  A little about ProtoLife

<img alt="ProtoLife PDT UI" src="resources/PDT-ESD.png" style="border: none; width: 750px;">

note:
* ProtoLife's website offers an easy to use interface for the optimization of high-throughput
scientific experiments, typically found in biotech, materials development, and process design.
* Target customer is individual scientist.
* What's interesting about our technology is that it is about "small data" rather than "big data".
* Typically scientists may incur substantial costs when performing an individual experiment,
so ProtoLife's "small data" algorithms are specially designed to find optimal responses when
the sample size is much smaller than seen in more common deep-learning systems that have
the advantage of "big data" sets.
* Here's how the system works: a set of laboratory experiments with varying input parameters are
performed and the responses are measured, uploaded to the ProtoLife Elm interface and
submitted to the backend where they are processed using carefully tailored algorithms written
in the R language.
* The algorithms explore the experimental space searching for optimal outcomes. Within seconds or
minutes, the next set (or "generation" as we call it) of optimized input parameters is displayed
in the user interface, and the experimental cycle is repeated until adequate outcomes are
achieved.
* Because of the very small size of the data sets involved, ProtoLife's algorithms are tightly
controlled to avoid becoming too complex and noisy, which might result in models that fit too
closely to the limited data already analyzed and miss the big picture that would be obtained with
larger numbers of future experimental responses.

* Some of the bits I enjoyed coding in Elm for this project (besides the CSS animations):
    * Extending the Handsontable Polymer web component with more DOM CustomEvents so Elm can listen for them
    * Using Html.Keyed to manage web component lifecycles when Elm and Polymer don't always play well together
    * Using Cmd and Sub ports to handle the Shiny Server message API
    * Learning how to code a native module and create an Http-like Request and Task system

Resources:
* [ProtoLife White Paper: Predictive Design Technology](https://protolife.com/pdf/White.pdf)
