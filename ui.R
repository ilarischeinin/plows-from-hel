library(leaflet)
library(shiny)

shinyUI(fillPage(title="Plows from HEL",
  leafletOutput("leaflet", height="100%"),
  absolutePanel(bottom=0L, width="100%",
    wellPanel(
      column(3L, radioButtons("which", label=NULL,
        choices=list("bicycle and pedestrian lanes"="kv", "streets"="st"),
        selected="kv")),
      column(3L, radioButtons("what", label=NULL,
        choices=list("snow removal"="au", "spreading sand"="hi",
        "brushing"="hj", "de-icing with salt"="su"), selected="au")),
      column(3L, sliderInput("hours", label="past hours to show",
        min=0L, max=24L, value=c(0L, 3L), step=1L, round=TRUE)),
      column(3L, p("This app shows the recent activity of",
        a(href="http://dev.hel.fi/apis/snowplows/", "snowplows in Helsinki."),
        "Made by Ilari Scheinin, source code on",
        a(href="https://github.com/ilarischeinin/plows-from-hel", "GitHub."),
        "See also the prettier",
        a(href="http://www.auratkartalla.com", "Aurat kartalla."),
        br(), br(), "Data updated: ", textOutput("stamp", inline=TRUE))),
      div(style="clear: both;")
    )
  )
))

# EOF
