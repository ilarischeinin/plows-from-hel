library(dplyr)
library(jsonlite)
library(leaflet)
library(leaflet.extras)
library(lubridate)
library(shiny)
library(stringr)

init_routes <- function() {
  url <- "http://dev.hel.fi/aura/v1/snowplow/"
  download_routes <- function(since="1days+ago") {
    plows <- fromJSON(paste0(url, "?since=", since))
    lapply(plows$id, function(id, since) {
      plow <- fromJSON(paste0(url, id, "?since=", since))
      coords <- t(sapply(plow$location_history$coords, FUN=c))
      events <- sapply(plow$location_history$events,
        function(x) paste(sort(x), collapse=","))
      data_frame(
        id=plow$id,
        timestamp=ymd_hms(plow$location_history$timestamp, tz="Europe/Helsinki"),
        latitude=coords[, 2],
        longitude=coords[, 1],
        events=events
      )
    }, since=since) %>%
      bind_rows()
  }

  if (file.exists("routes.rds")) {
    message("Loading saved routes")
    routes <- readRDS("routes.rds")
  } else {
    message("Downloading routes")
    stamp <- now()
    routes <- download_routes()
    attr(routes, "stamp") <- stamp
    rm(list="stamp")
  }

  reg.finalizer(environment(),
    function(e) saveRDS(routes, "routes.rds"), onexit=TRUE)

  function() {
    if (difftime(now(), attr(routes, "stamp"), units="mins") <= 15) {
      message("No need to update")
      return(routes)
    }
    # from <- max(max(routes$timestamp), now()-1*24*60*60)
    from <- max(attr(routes, "stamp"), now()-1*24*60*60)
    message("Updating routes since: ", from)
    stamp <- now()
    from <- format(from, "%Y-%m-%dT%H:%M:%S", tz="UTC")
    tmp <- bind_rows(routes, download_routes(from)) %>%
      filter(timestamp > now()-1*24*60*60)
    attr(tmp, "stamp") <- stamp
    routes <<- tmp
    rm(list=c("tmp", "stamp"))
    # saveRDS(routes, "routes.rds", compress=FALSE)
    routes
  }
}

get_routes <- init_routes()

# pal <- colorBin("Purples", domain=c(0, 24), bins=c(0, 1, 3, 6, 12, 24))

shinyServer(function(input, output) {
  session_routes <- get_routes()
  hour <- difftime(now(), session_routes$timestamp, unit="hours")
  selected_routes <- reactive({
    # if (input$which == "kv") {
    #   cond <- str_detect(session_routes$events, "kv")
    # } else {
    #   cond <- !str_detect(session_routes$events, "kv")
    # }
    cond <- str_detect(session_routes$events, input$what) &
      hour >= input$hours[1] & hour <= input$hours[2]
    session_routes[cond, ]
  })
  output$stamp <- renderText(paste(attr(session_routes, "stamp")))
  output$leaflet <- renderLeaflet({
    leaflet() %>%
      addTiles(group="OpenStreetMap") %>%
      # these apparently don't support https, breaking geolocating:
      # addProviderTiles("OpenStreetMap.BlackAndWhite",
      #   group="OpenStreetMap - Black and White") %>%
      # addProviderTiles("HikeBike.HikeBike",
      #   group="OpenStreetMap - Hike & Bike") %>%
      addProviderTiles("OpenTopoMap",
        group="OpenStreetMap - OpenTopoMap") %>%
      addProviderTiles("Thunderforest.OpenCycleMap",
        group="Thunderforest - OpenCycleMap") %>%
      addProviderTiles("Thunderforest.Transport",
        group="Thunderforest - Transport") %>%
      addProviderTiles("Thunderforest.TransportDark",
        group="Thunderforest - Transport Dark") %>%
      addProviderTiles("Thunderforest.Landscape",
        group="Thunderforest - Landscape") %>%
      addProviderTiles("Thunderforest.Outdoors",
        group="Thunderforest - Outdoors") %>%
      addTiles(urlTemplate=
        "https://{s}.tile.thunderforest.com/spinal-map/{z}/{x}/{y}.png",
        attribution=paste('&copy;',
        '<a href="http://www.opencyclemap.org">OpenCycleMap</a>, &copy;',
        '<a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'),
        group="Thunderforest - Spinal Map") %>%
      setView(24.95, 60.19, zoom=13) %>%
      # addLegend("topright", pal=pal,
      #   values=0:24, title="hours ago", opacity = 1) %>%
      addLayersControl(
        baseGroups=c("OpenStreetMap", "OpenStreetMap - Black and White",
        "OpenStreetMap - Hike & Bike", "OpenStreetMap - OpenTopoMap",
        "Thunderforest - OpenCycleMap", "Thunderforest - Transport",
        "Thunderforest - Transport Dark", "Thunderforest - Landscape",
        "Thunderforest - Outdoors", "Thunderforest - Spinal Map")) %>%
      addFullscreenControl() %>%
      addControlGPS()
  })
  observe({
    map <- leafletProxy("leaflet") %>%
      clearShapes()
    sel <- selected_routes()
    lapply(unique(sel$id), function(id) {
      addPolylines(map, data=sel[sel$id == id, ], ~longitude, ~latitude,
        # color=~pal(as.numeric(difftime(now(), timestamp, unit="hours"))))
        color="blue")
    })
  })
  observeEvent(input$toggle, {
    toggle("controls")
  })
})

# EOF
