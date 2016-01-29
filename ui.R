
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Brazil Locations Data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      sliderInput("sldLat", label = h3("Latitude"), min = -34, max = 6, value = c(-34, 6)),
      sliderInput("sldLon", label = h3("Longitude"), min = -74, max = -31, value = c(-74, -31)),
      sliderInput("sldAlt", label = h3("Altitude"), min = 0, max = 1640, value = c(0, 1640)),
      textInput("txtCity", label = h3("City Name")),
      selectInput("cmbUF", label = h3("State"), choices = c("All" = ""))
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Plot",
      plotOutput("brazilPlot", hover = hoverOpts(id ="plot_hover")),
      tableOutput("hover_info")
      ),
      tabPanel('Dataset', DT::dataTableOutput('dt_tbl'))
    )
  )
)))
