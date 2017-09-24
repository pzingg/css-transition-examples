# CSS Transitions in Elm


## Alert and InfoBox Widgets

The src folder contains "shared view" code for three modules:

* `Alert` module for animated alerts (or "flash" messages).

* `AlertWithSub` module: a slight variant of the `Alert` module that uses the
`AnimationFrame.times` Sub function to ensure that initial views are rendered for at
least one animation frame cycle.

* `InfoBox` module for animated blocks of text triggered by an icon click.


## Demo Application

See the [README.md file in the demo/ directory](demo/) for an application that shows the
client code for these modules, as well as a router transition UI that also uses
CSS transitions.

To build the app:

```bash
cd demo
elm-make --output=TransitionsDemo/elm.js TransitionsDemo/Main.elm
```

Then open the demo/index.html file in a browser.


## ElmConf 2017 Presentation

Reveal.js presentation sources are in the slides/ directory. To build static presentation
files into slides/dist/:

```bash
cd slides
grunt dist
cd ..
```

More information on the slide deck is in the  [README.md file in the slides/ directory](slides/).

Then hyperlinks from the slides to the demo application and back will work if you run a static
web server in the project directory:

```bash
python -m SimpleHTTPServer 8080
```

And go to the first slide at http://localhost:8080/slides/dist/

And the demo application will be at http://localhost:8080/demo/
