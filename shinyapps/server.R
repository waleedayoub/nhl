library(shiny)
library(shinyapps)
library(ggplot2)
# load the other libraries

ptsData.byDate <- readRDS('ptsDatabyDate.rds')

head(ptsData)
# Define a server for the Shiny app
shinyServer(function(input, output) {
  
  # Fill in the spot we created for a plot
  output$ptsDatePlot <- renderPlot({
    
    # Render a barplot
    ggplot(ptsData.byDate, aes(x=date, y=cumpts, colour=POOL_MEMBER)) + ylab("Points") + 
      geom_line(aes(group=POOL_MEMBER))
    
  })
})