# CSS Transitions in Elm

The src folder contains "shared view" code for three modules:

* `Alert` module for animated alerts (or "flash" messages).

* `AlertWithSub` module: a slight variant of the `Alert` module that uses the
`AnimationFrame.times` Sub function to ensure that initial views are rendered for at
least one animation frame cycle.

* `InfoBox` module for animated blocks of text triggered by an icon click.

See the README.md file in the demo/ directory for an application that shows the
client code for these modules, as well as a router transition UI that also uses
CSS transitions.
