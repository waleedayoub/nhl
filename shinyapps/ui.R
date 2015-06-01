library(shiny)

# Rely on the 'WorldPhones' dataset in the datasets
# package (which generally comes preloaded).
library(datasets)

# Define the overall UI
shinyUI(
  
  # Use a fluid Bootstrap layout
  fluidPage(    
    
    # Give the page a title
    titlePanel("Pool Performance by Date"),

      
      # Create a spot for the barplot
      mainPanel(
        plotOutput("ptsDatePlot")  
      )
      

  )
)