library(leaflet)
library(shiny)
library(shinyjs)

shinyUI(fillPage(title="Plows from HEL",
  useShinyjs(),
  leafletOutput("leaflet", height="100%"),
  absolutePanel(id="controls", bottom=0L, width="100%",
    wellPanel(
      column(3L, radioButtons("which", label=NULL,
        choices=list("bicycle and pedestrian lanes"="kv", "streets"="st"),
        selected="kv")),
      column(3L, radioButtons("what", label=NULL,
        choices=list("snow removal"="au", "spreading sand"="hi",
        "brushing"="hj", "de-icing with salt"="su"), selected="au")),
      column(3L, sliderInput("hours", label="past hours to show",
        min=0L, max=24L, value=c(0L, 3L), step=1L, round=TRUE)),
      column(3L, p(style="font-size: smaller;",
        "This app shows the recent activity of snowplows in Helsinki.",
        "Made by Ilari Scheinin, source code on",
        a(href="https://github.com/ilarischeinin/plows-from-hel", "GitHub."),
        "Data comes from", a(href="http://www.hel.fi/stara", "Stara's"),
        a(href="http://dev.hel.fi/apis/snowplows/", "API,"),
        "which contains only a subset of all plows in use.",
        "See also Sampsa Kuronen's",
        a(href="http://www.auratkartalla.com", "Aurat kartalla"),
        "for a prettier overview."
        , br(), "Data updated: ", textOutput("stamp", inline=TRUE)
      )),
      div(style="clear: both;")
    )
  ),
  absolutePanel(bottom=25L, left=5L, actionButton("toggle", label="X",
    style="font-size: xx-small;"))
))

# EOF
