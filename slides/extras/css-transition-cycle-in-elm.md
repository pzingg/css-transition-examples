##  The CSS transition cycle in Elm

<img alt="A CSS transition example" src="resources/TransitionsPrinciple.png" style="height: 150px; border: none;">

<ol>
<li class="fragment"><code>view</code> - render <strong>initial</strong> values for properties
<li class="fragment">Handle triggering event in <code>update</code> - change model state
<li class="fragment"><code>view</code> - render <strong>target</strong> values
<li class="fragment">Handle <code>transitionend</code> in <code>update</code> - change model state
<li class="fragment">Optionally change DOM again in <code>view</code>
</ol>

note:
    Image credit: https://developer.mozilla.org/files/4529/TransitionsPrinciple.png
