Plows from HEL
==============

This repository contains R code to
[visualize](http://ilari.scheinin.fi/shiny/plows/) recent routes and activities
of snowplows in Helsinki, Finland. It uses [shiny](http://shiny.rstudio.com)
and the [R wrapper](https://rstudio.github.io/leaflet/) for the
[leaflet](http://leafletjs.com) JavaScript library. Data is fetched from the
[City of Helsinki API](http://dev.hel.fi/apis/snowplows/).

[Aurat kartalla](http://www.auratkartalla.com) already provides a prettier
visualization of the same data, and with better performance. However, for
bicycle/pedestrian lanes, it doesn't distinguish between different activities
(snow removal, spreading sand, brushing, de-icing with salt). Also, when
multiple activities have been performed at the same location, the overlapping
colors can sometimes be not that easy to distinguish.

The purpose of this app is therefore to unambiguously show what actions have
been performed, and whether on bicycle/pedestrian lanes or on the streets.
