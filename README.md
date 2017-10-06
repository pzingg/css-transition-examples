# CSS Transitions in Elm

This is the repository containing the slide deck sources (with speaker notes) and sample
code for a talk I gave at ElmConf US in St. Louis in September 2017.

The [video for the talk](https://youtu.be/Zje8MN9whF0) has been posted! Thanks to \@BrianHicks
and \@lukewestby for organizing this wonderful get-together, helping me hone the talk,
and doing all the hard work that continued after the conference to get the talks online.

You can see all of the talks (as of October 5, 6 have been posted so far) on
the [elm-conf US 2017 YouTube playlist](https://www.youtube.com/playlist?list=PLglJM3BYAMPFTT61A0Axo_8n0s9n9CixA).

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
cd ..
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
python -m SimpleHTTPServer 8000
```

And go to the first slide at http://localhost:8000/slides/dist/

And the demo application will be at http://localhost:8000/demo/


## Other Animation Resources

These are all great resources if you want to explore fundamentals of animation in Elm:

* http://package.elm-lang.org/packages/elm-lang/animation-frame/latest
* http://package.elm-lang.org/packages/mgold/elm-animation/latest
* http://package.elm-lang.org/packages/rundis/elm-bootstrap/latest
* http://package.elm-lang.org/packages/debois/elm-mdl/latest (especially the Material.Ripple module)
* http://package.elm-lang.org/packages/mdgiffith/elm-style-animation/latest
* http://package.elm-lang.org/packages/mdgiffith/style-elements/latest (CSS Transitions are supported in the Style.Transition module)

And if you're interested in the "page transitions" example, here are some proposals from
Chrome browser developers and the Angular community:

* [Navigation Transitions project (JavaScript)](https://github.com/jakearchibald/navigation-transitions)
* [Router Transitions in Angular 4.3](https://medium.com/google-developer-experts/angular-supercharge-your-router-transitions-using-new-animation-features-v4-3-3eb341ede6c8)
