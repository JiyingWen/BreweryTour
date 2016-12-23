
library(shiny)
library(leaflet)
library(shinyBS)
library(shinythemes)

shinyUI(navbarPage(theme=shinytheme("cosmo"),
                   title = "Craft Brewery Vancouver", 
                   tabPanel("Brewery Map",
                            sidebarLayout(
                              sidebarPanel(
                                selectInput("choose_brewery", strong("Brewery:"), c("",as.list(levels(locDat$brewery))), selected = "", multiple = F), hr(),
                                bsTooltip("choose_brewery", "Enter a brewery. The menu will filter as you type. You may also select a brewery using the map.", "center", options = list(container="body")),
                                strong(textOutput("text_add")), hr(),
                                strong(textOutput("beer")), 
                                dataTableOutput("beer_table")
                                ),

                              mainPanel(
                                leafletOutput("Map", width = 750, height = 600)
                              )
                            )
                   ),
                   tabPanel("Tour Planner",
                            sidebarLayout(
                              sidebarPanel(
                                img(src="vancouver_brewery_tours.png", height = 175, width = 300), hr(),
                              numericInput('nbreweries', 'How many breweries do you want to visit?', 10,
                                           min = 2, max = 31),
                              sliderInput("visit_time","How long do you want to spend at each brewery?", value = 0.5, min=0.5, max=2, step=0.5), hr(),
                              strong(textOutput("distTitle")),
                              strong(textOutput("timeTitle"))
                              ),
                              mainPanel(
                                leafletOutput("Map2", width = 750, height = 600)
                              )
                            )
                   ),

                   tabPanel("About", source("about.R",local=T)$value)
)
)