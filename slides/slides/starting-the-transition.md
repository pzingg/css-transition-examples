##  Starting the transition

<blockquote>Various things can cause the computed values of properties on an element to change.
These include insertion and removal of elements from the document tree (which both changes whether
those elements have computed values and can change the styles of other elements through selector
matching), changes to the document tree that cause changes to which selectors match elements,
changes to style sheets or style attributes,</blockquote>

<blockquote>...and other things.</blockquote>

note:
* Just use your Elm view function to set the initial values of properties you want to animate,
then at a later time, change the view to set the target values using the `style` attributes
function.


Image credits:
* https://developer.mozilla.org/files/4529/TransitionsPrinciple.png

Resources:
* [CSS Transitions Working Draft](https://drafts.csswg.org/css-transitions/)
