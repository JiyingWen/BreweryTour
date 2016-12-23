###########################
## Server.R
###########################

library(shiny)
library(leaflet)
library(rMaps)
library(rCharts)
library(dplyr)

shinyServer(function(input, output, session){
  # Data prepration
  bDat_sm <- reactive({
    if(is.null(input$choose_brewery)){
      return(NULL)
    }
    bDat %>%
      filter(brewery==input$choose_brewery) %>%
      droplevels()
  }) 
  
# render map and popup information
  output$Map <- renderLeaflet({
    leaflet(data = locDat) %>% addProviderTiles("CartoDB.Positron") %>% setView(-122.8, 49.26, 10) %>%
      addMarkers(~lon, ~lat,
                       layerId = ~ brewery, popup =paste(paste('<h3>', bdat$brewery, '</h3>'), "<br>",
                                                         paste('<h4>', "Average Rating:",round(bdat$rating_average, 2), '</h4>'), "<br>",
                                                         paste('<em style="color: hotpink">', "Ranked within TOP", (round((1 - bdat$Top),3)*100), "% of the breweries", '</em>')))
  })

  # create instance for map click
  observeEvent(input$Map_marker_click, {
    p <- input$Map_marker_click
    if(p$id=="Selected"){
      leafletProxy("Map") %>% removeMarker(layerId="Selected")
    } else {
      leafletProxy("Map") %>% setView(lng=p$lng, lat=p$lat, 12) %>%
        addCircleMarkers(p$lng, p$lat, radius=10, color="orange", fillColor="",
                         fillOpacity=0, opacity=1, stroke=TRUE, layerId="Selected")
    }
  })

  # update the menu if the user clicks a location on the map
  observeEvent(input$Map_marker_click, {
   p <- input$Map_marker_click
    if(!is.null(p$id)){
      if(is.null(input$choose_brewery)) updateSelectInput(session, "choose_brewery", selected=p$id)
      if(!is.null(input$choose_brewery) && input$choose_brewery!=p$id)
        updateSelectInput(session, "choose_brewery", selected=p$id)
    }
  })

  observeEvent(input$choose_brewery, {
    p <- input$Map_marker_click
    p2 <- subset(locDat, brewery==input$choose_brewery)
    if(nrow(p2)==0){
      leafletProxy("Map") %>% removeMarker(layerId="Selected")
    } else if(input$choose_brewery!= p$id){
      leafletProxy("Map") %>% setView(lng=p2$lon, lat=p2$lat, input$Map_zoom) %>%
        addCircleMarkers(p2$lon, p2$lat, radius=10, color="orange", fillColor="",
                         fillOpacity=0, opacity=1, stroke=TRUE, layerId="Selected")
    }
  })

 # generate a table for selected brewery
 output$beer_table <- renderDataTable({
   bDat_sm()  %>% select(Name, round(Rating, 1)) %>%
     arrange(desc(Rating))
 }, options = list(pageLength = 10,
                   searching = F,
                   digits = 2,
                   lengthMenu = list(c(10, -1), list('10', 'All'))
                   ))

 # output for location, beer type/rating
 output$text_add <- renderText({
   paste("Location:", levels(bDat_sm()$address))
 })
 
 output$beer <- renderText({ 
   "Beer and Rating:"
 })
   
#################################################
 # tour planner
op_route <- reactive({
  B = 500
  ind = list()
  outlist <- vector("list", B)
  score = numeric(B)
  for (i in 1:B)
  {
    ind[[i]] = sample(1:31, input$nbreweries, replace = F)
    smatrix = optim_matrix[ind[[i]], ind[[i]]]
    outlist[[i]] = tsp.route(smatrix, brewery_name[ind[[i]]])
    score[i] = outlist[[i]]$score
  }
  optimal_route = outlist[[which.min(score)]]
})


 sorted.route <- reactive({
   droplevels(data.frame(locDat[match(op_route()$route, locDat$brewery),], row.names = NULL))})

 sorted.route2 <- reactive({
   sorted.route() %>%
     mutate(nstop = 1:nrow(sorted.route())) %>%
     mutate(color = c("green", rep("blue", nrow(sorted.route()) - 2), "red"))
 })
 
 # calculate total distance
 distance_travelled <- reactive({round(op_route()$distance.travelled, 1)})
 output$distTitle <- renderText({
   paste("Total Distance:", distance_travelled(), "km")
 })
 
 # calculate total time
 trip_time <- reactive({round(op_route()$trip.time,1)})
 output$timeTitle <- renderText({
   N <- input$nbreweries
   V <- input$visit_time
   D <- trip_time()
   paste("Estimated Time:", D + N*V, "h")
 })
 
 # customize icon
Icons <- iconList(blue = makeIcon("blue.png", iconWidth = 24, iconHeight =40),
                        green = makeIcon("green.png", iconWidth = 24, iconHeight =40),
                        red = makeIcon("red.png", iconWidth = 24, iconHeight =40))
 
# output map with route
 output$Map2 <- renderLeaflet({
   leaflet(data = sorted.route2()) %>% addProviderTiles("CartoDB.Positron") %>% 
     addMarkers(~lon, ~lat, icon = ~Icons[color],
                layerId = ~ brewery, popup =paste(
                  paste('<h3>', "Stop#", sorted.route2()$nstop, sorted.route()$brewery, '</h3>'),
                  paste(paste('<h4>', "Average Rating:", round(bdat$rating_average, 2), '</h4>')), 
                 paste('<em style="color: hotpink">', "Ranked within TOP", (round((1 - bdat$Top),3)*100), "% of the breweries", '</em>'))) %>%
     addPolylines(lat = ~lat, lng = ~lon)
 })
})