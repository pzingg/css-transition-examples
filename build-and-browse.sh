#!/bin/bash

cd slides
grunt dist
cd ../demo
elm-make --output=TransitionsDemo/elm.js TransitionsDemo/Main.elm
cd ..
python -m SimpleHTTPServer 8000 &
xdg-open 'http://localhost:8000/slides/dist'
