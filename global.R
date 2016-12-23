#### global
library(shiny)
library(leaflet)
library(dplyr)

# load data
bDat <- read.csv("./data/brewery.csv")
locDat <- read.csv("./data/brewery_locinfo.csv", row.names = NULL)
optim_matrix = readRDS("./data/myOptim.rds")
total_time = readRDS("./data/DurMatrix.rds")
DistMatrix = readRDS("./data/DistMatrix.rds")

# functions
# function1 capitalize the first letter of a word
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

# function 2 TSP
tsp.route <- function(places, names){
  require("TSP")
  items <- as.numeric(NROW(names))
  city.matrix <- matrix(places, nrow=items, ncol=items, dimnames=list(names,names))
  tsp <- ATSP(city.matrix)
  
  methods <- c("nearest_insertion", "farthest_insertion", 
               "cheapest_insertion","arbitrary_insertion","nn", 
               "repetitive_nn", "2-opt")
  
  
  tours <- sapply(methods, FUN = function(m) 
    solve_TSP(tsp,method = m),simplify=FALSE)
  best <- tours[which.min(c(sapply(tours, FUN = attr, "tour_length")))]
  best.route <- names(best[[1]])
  best.score <- tour_length(tsp, best[[1]])
  c1 = match(best.route, brewery_name)
  t = numeric(items-1)
  d = numeric(items-1)
  for (j in 1: (items - 1)){
    t[j] = total_time[c1[j], c1[j+1]]
    d[j] = DistMatrix[c1[j], c1[j+1]]
  }
  total.time = sum(t)/3600
  total.distance = sum(d)/1000
  
  
  output <- list(route = best.route, score = best.score, distance.travelled = total.distance , trip.time = total.time)
  
  return(output)            
}

# data prep
locDat$brewery <- sapply(as.character(locDat$brewery),  simpleCap)
locDat$brewery <-  factor(locDat$brewery)

bDat$brewery <-  sapply(as.character(bDat$brewery), simpleCap)
bDat$brewery <-  factor(bDat$brewery)

bDat <- bDat %>%
  dplyr::mutate(rating = round(Rating,2)) %>%
  select(-Rating) %>%
  dplyr::rename(Rating = rating, Name = name)

bdat = bDat %>%
  #filter(brewery==input$choose_brewery) %>%
  group_by(brewery) %>%
  dplyr::summarize(rating_average = sum(Rating*NReviews)/sum(NReviews),
                   nbeers = n()) 

percentage = ecdf(bdat$rating_average)

bdat = bdat %>%
  mutate(Top = percentage(rating_average))

brewery_name = bdat$brewery




