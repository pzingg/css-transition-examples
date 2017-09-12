##  Other Elm animation packages

Some great Elm modules to help build animations

<ul>
<li class="fragment">elm-lang/animation-frame
<li class="fragment">mgold/elm-animation
<li class="fragment">rundis/elm-bootstrap
<li class="fragment">debois/elm-mdl package (Material.Ripple module)
<li class="fragment">mdgiffith/elm-style-animation package
<li class="fragment">mdgiffith/style-elements package (Style.Transition module)
</ul>

note:
* That's it for the basics of animation and initial timing!

* My goals for these examples were to:
    * Avoid resorting to heavy-duty animation calculations
    * Keep code as pure Elm as possible, with little or no JavaScript
    * Use simple code without a lot of dependencies
    * Avoiding Subs if you don't need them, to keep things simple

* But if you need more sophistication, you could:
    * Do the math yourself with elm-lang/animation-frame
    * Let mgold/elm-animation do the math and give you a powerful API to wire things up
    * Use rundis/elm-bootstrap for an all-Bootstrap UI
        (disclaimer - a lot of the ideas and coding details in this talk come from this package)
    * Take a look at some of the more complex and integrated UI packages being released and updated every month
    * Write an Elm port interface to the Web Animations API
