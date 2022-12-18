library(shiny)
library(leaflet)
library(tidyverse)
library(plyr)
library(dplyr)
library(conflicted)
library(vroom)
library(readr)
library(tidyverse)
library(shiny)
library(maps)
library(ggmap)
conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")

# Shiny App
stops <- read_csv("stops.txt")
stops <- select(stops,c(1,2,3,7,8,9))
stops <- na.omit(stops)
stops$stop_id <- as.integer(stops$stop_id)

HR <- vroom("HRTravelTimesQ4_21.csv")
LR <- vroom("LRTravelTimesQ4_21.csv")
HR1 <- HR %>%
  distinct(from_stop_id, to_stop_id, route_id, .keep_all = TRUE)
LR1 <- LR %>% 
  distinct(from_stop_id, to_stop_id, route_id, .keep_all = TRUE)
TraTime <- rbind(HR1, LR1)
TraTime2 <- TraTime %>% select(from_stop_id, route_id)

names(TraTime2) <- c("stop_id","lines")
TraTime2 <- inner_join(TraTime2,stops,by="stop_id")



ui <- fluidPage(
  selectInput("from", "Start", TraTime2$stop_name),
  selectInput("to", "End", TraTime2$stop_name),
  selectInput("line", "choose a line",
              choices = unique(TraTime2$lines),
              multiple = FALSE),
  leafletOutput("plot")
)
server <- function(input, output, session) {
  output$plot <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      setView(lng = -71.0589, lat = 42.3601, zoom = 10) %>% 
      addMarkers(lng = TraTime2$stop_lon,
                 lat = TraTime2$stop_lat,
                 popup = TraTime2$stop_name)})}
shinyApp(ui=ui,server=server)



