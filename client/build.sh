#!/usr/bin/bash

sass sass/main.sass:dist/css/main.css && \
    elm make src/Main.elm --output dist/js/app.js
