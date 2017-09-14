# CSS Transitions Demo Application

This demo uses the `elm-live` dev server.

Install `elm-live` node module with `npm install -g elm-live`.

Start the dev server with `elm-live  --debug --pushstate --output=TransitionsDemo/elm.js TransitionsDemo/Main.elm`.

Then navigate to `http://localhost:8000/`.

### Application Notes

The application is a simple Elm SPA demonstrating three different CSS transition user interfaces:

1.  Alert widget that is initially closed, but opens with animation when called programmatically.
2.  Info box widget that expands when an element is clicked.
3.  A router transition effect, adapted from Bootstrap's Carousel component, that slides page
    content in from the right when the active route is changed.

No JavaScript is required for the animations themselves, but we do use some JavaScript ports:

1.  When we want to open an alert, we call a port that dispatches a custom DOM event so that we can
    find out the height of the content we'll be expanding.
2.  Before we start the router transition animation, we call a port that gets the offsetWidth of
    the content that will be animated directly.

The application itself is expanded from this example: <https://github.com/sporto/elm-navigation-pushstate>

The host HTML file that loads the JavaScript ports and the required Bootstrap CSS is index.html.


### Notes on the router transition demo

Here's the part of bootstrap.css that deals with carousel transitions:

```css
@media all and (transform-3d), (-webkit-transform-3d) {
  .carousel-inner > .item {
    transition: transform .6s ease-in-out;
    backface-visibility: hidden;
    perspective: 1000px;
  }

  .carousel-inner > .item.next {
    left: 0;
    transform: translate3d(100%, 0, 0);
  }

  .carousel-inner > .item.active.left {
    left: 0;
    transform: translate3d(-100%, 0, 0);
  }

  .carousel-inner > .item.next.left,
  .carousel-inner > .item.active {
    left: 0;
    transform: translate3d(0, 0, 0);
  }
}
```

And here's the code from bootstrap.js that shows how the class names are used to
effect different transition states.  

`type` is either `'next'` or `'prev'` and `next` is the object we are sliding to.

```js
Carousel.prototype.slide = function (type, next) {
  var $active   = this.$element.find('.item.active')
  var $next     = next || this.getItemForDirection(type, $active)
  var isCycling = this.interval
  var direction = type == 'next' ? 'left' : 'right'
  var that      = this

  if ($next.hasClass('active')) return (this.sliding = false)

  var relatedTarget = $next[0]
  var slideEvent = $.Event('slide.bs.carousel', {
    relatedTarget: relatedTarget,
    direction: direction
  })
  this.$element.trigger(slideEvent)
  if (slideEvent.isDefaultPrevented()) return

  this.sliding = true

  isCycling && this.pause()

  if (this.$indicators.length) {
    this.$indicators.find('.active').removeClass('active')
    var $nextIndicator = $(this.$indicators.children()[this.getItemIndex($next)])
    $nextIndicator && $nextIndicator.addClass('active')
  }

  var slidEvent = $.Event('slid.bs.carousel', { relatedTarget: relatedTarget, direction: direction }) // yes, "slid"
  if ($.support.transition && this.$element.hasClass('slide')) {
    $next.addClass(type)
    $next[0].offsetWidth // force reflow
    $active.addClass(direction)
    $next.addClass(direction)
    $active
      .one('bsTransitionEnd', function () {
        $next.removeClass([type, direction].join(' ')).addClass('active')
        $active.removeClass(['active', direction].join(' '))
        that.sliding = false
        setTimeout(function () {
          that.$element.trigger(slidEvent)
        }, 0)
      })
      .emulateTransitionEnd(Carousel.TRANSITION_DURATION)
  } else {
    $active.removeClass('active')
    $next.addClass('active')
    this.sliding = false
    this.$element.trigger(slidEvent)
  }

  isCycling && this.cycle()

  return this
}
```

So, in Elm, start of transition should do this:

```js
$next.addClass(type)
$next[0].offsetWidth // force reflow
$active.addClass(direction)
$next.addClass(direction)
```

And end of transition should do this:

```js
$next.removeClass([type, direction].join(' ')).addClass('active')
$active.removeClass(['active', direction].join(' '))
that.sliding = false
```
