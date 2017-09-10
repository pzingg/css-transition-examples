##  CSS transition cycle in Elm

<img alt="A CSS transition example" src="resources/TransitionsPrinciple.png" style="height: 150px; border: none;">

<ol>
<li class="fragment"><code style="background-color: moccasin">view</code> - paint <strong>initial</strong> values for properties
<li class="fragment">Handle triggering event in <code style="background-color: moccasin">update</code> - change model state
<li class="fragment"><code style="background-color: moccasin">view</code> - paint <strong>target</strong> values
<li class="fragment">Handle <code style="background-color: moccasin">transitionend</code> in <code style="background-color: moccasin">update</code> - change model state
<li class="fragment">Optionally change DOM again in <code style="background-color: moccasin">view</code>
</ol>

note:
    Image credit: https://developer.mozilla.org/files/4529/TransitionsPrinciple.png
