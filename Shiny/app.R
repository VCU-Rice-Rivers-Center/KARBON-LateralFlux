
#####################
### Load Packages ###
#####################

library(shiny)
library(tidyverse)
library(bslib)
library(plotly)
library(ggplot2)

source("shiny_functions.R")

###############
### UI Code ###
###############

ui <- page_fluid(
  navset_pill(
    nav_panel("Overview"),
    nav_panel("Exo Variables"),
    nav_panel("ADCP Variables"),
    nav_panel("Flux Variables",
              sidebarLayout(
                sidebarPanel(
                  checkboxGroupInput("flux_vars", "Variables", 
                                     choices = c(
                                       "H2O", "CH4", "cavity_p", "cavity_t",
                                       "CO2_LI850","H2O_LI850","CellTemp_LI850","CellPres_LI850"
                                     ),
                                     selected = c("CH4", "CO2_LI850")
                  )
              ),
              mainPanel(
                plotlyOutput("plot_flux")
              )
            )
    ),
    nav_panel("Rad7 Variables")
  )
)

server <- function(input, output, session) {
  # Grab data
  exo <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/main/Data/Processed/KARBON_EXO.csv")
  flux <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/main/Data/Processed/KARBON_FLUX.csv")
  adcp <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/main/Data/Processed/KARBON_HYDROLOGY.csv")
  rad7 <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/main/Data/Processed/KARBON_RADON.csv")
  
  # min_date <- min(c(exo$TIMESTAMP, flux$TIMESTAMP, adcp$TIMESTAMP, rad7$TIMESTAMP), na.rm = TRUE) %>% as_date()
  
  # Temporary min_date bc we don't have a month of data yet:
  min_date <- min(flux$TIMESTAMP, na.rm = TRUE) %>% as_date()
  max_date <- max(c(exo$TIMESTAMP, flux$TIMESTAMP, adcp$TIMESTAMP, rad7$TIMESTAMP), na.rm = TRUE) %>% as_date()
  
  updateDateInput(session, "start_date", value = max_date - days(7), min = min_date, max = Sys.Date())
  updateDateInput(session, "end_date", value = max_date, min = min_date, max = Sys.Date())
  
  output$plot_flux <- renderPlotly({
    make_plot(flux, input$flux_vars, min_date, max_date)
  })
  
}

shinyApp(ui, server)
