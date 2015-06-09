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
    
    sidebarLayout(
      sidebarPanel(
        h4("Pool Standings"),
        tableOutput("ptsTable")
      ),
      # Create a spot for the barplot
      mainPanel(
        h4("Cumulative Points by Date"),
        plotOutput("ptsDatePlot")  
      )
    )      

  )
)