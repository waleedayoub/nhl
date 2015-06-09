library(shiny)
library(shinyapps)
library(ggplot2)
library(dplyr)
library(scales)
# load the other libraries

ptsData.byDate <- readRDS('ptsDatabyDate.rds')
ptsData.byDate$date <- as.Date(ptsData.byDate$date)

# ptsData.byDate <- readRDS('./shinyapps/ptsDatabyDate.rds')
ptsData.byMember <- group_by(ptsData.byDate, POOL_MEMBER) %>% 
  summarise(goals=sum(goals), assists=sum(assists), points = sum(points)) %>% 
  arrange(desc(points))

# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Fill in the spot we created for a plot
  output$ptsDatePlot <- renderPlot({
    
    # Render a time series line plot
    ggplot(ptsData.byDate, aes(x=date, y=cumpts, colour=POOL_MEMBER)) + ylab("Points") + 
      geom_line(aes(group=POOL_MEMBER)) +
      scale_x_date(breaks="3 days", labels=date_format("%b%d")) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
  })
  
  output$ptsTable <- renderTable({
    print(ptsData.byMember)
  })
})