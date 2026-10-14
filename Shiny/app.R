
#####################
### Load Packages ###
#####################

library(shiny)
library(tidyverse)
library(bslib)
library(plotly)
library(ggplot2)
library(here)

source(here("Shiny", "shiny_functions.R"))

###############
### UI Code ###
###############

ui <- page_fluid(
  
  theme = bs_theme(bootswatch = "sandstone"),
  
  tags$head(
    tags$style(HTML("
      .title-banner {
        background-image: 'www/images/KimagesCreek.jpg';
        background-size: cover;
        background-position: center;
        min-height: 150px;
        color: white;
        padding: 20px;
        margin: 10px;
      }
      .title-banner h1 {
        text-shadow: 0 2px 3px rgba(0,0,0,0.8);
      }
      .nav-pills {
        margin: 10px;
      }
      .tab-content {
        margin: 20px;
      }
      #overview div{
        width: 35vw;
        margin: auto;
        padding: 30px;
        border-radius: 20px;
        background-color: #f8f5f0;
        border-color: #dfd7ca;
        color: #8e8c84;
        border-width: 1px;
        border-style: solid;
      }
      #overview h2{
        text-transform: uppercase;
      }
      img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            border-radius: 10px;
      }
      h3 {
        text-transform: uppercase;
      }
    "))),
  
  # Banner
  div(class = "title-banner",
      h1("KARBON Lateral Transport at RRC")
  ),
  
  navset_pill(
    nav_panel("Overview",
              uiOutput("overview")),
    nav_panel("Exo",
              sidebarLayout(
                sidebarPanel(
                  h3("Date Range"),
                  dateInput("exo_start_date", "Start date"),
                  dateInput("exo_end_date", "End date"),
                  h3("Variables:"),
                  checkboxGroupInput("exo_vars", label=NULL,
                                     choices = c(
                                       "DO_mgL", "FDOM_RFU", "Chlorophyll_ugL", "Conductivity",
                                       "DO_saturation", "Salinity_PPT", "TDS_mgL", "pH", "Temp_C",
                                       "Depth_m"
                                     ), 
                                     selected = c("Depth_m", "Salinity_PPT")
                  ), width = 3
                ),
                mainPanel(
                  plotlyOutput("plot_exo",
                               width = "70vw", height = "70vh")
                )
              )
    ),
    nav_panel("ADCP",
              sidebarLayout(
                sidebarPanel(
                  h3("Date Range"),
                  dateInput("adcp_start_date", "Start date"),
                  dateInput("adcp_end_date", "End date"),
                  h3("Variables:"),
                  checkboxGroupInput("adcp_vars", label=NULL,
                                     choices = c(
                                       "Water_depth_m", "Flowrate_ms", "Index_velocity_ms",
                                       "Mean_velocity_ms"
                                     ),
                                     selected = c("Water_depth_m", "Index_velocity_ms")
                  ), width = 3
                ),
                mainPanel(
                  plotlyOutput("plot_adcp",
                               width = "70vw", height = "70vh")
                )
              )
    ),
    nav_panel("Flux",
              sidebarLayout(
                sidebarPanel(
                  h3("Date Range"),
                  dateInput("flux_start_date", "Start date"),
                  dateInput("flux_end_date", "End date"),
                  h3("Variables:"),
                  checkboxGroupInput("flux_vars", label=NULL,
                                     choices = c(
                                       "H2O", "CH4", "cavity_p", "cavity_t",
                                       "CO2_LI850","H2O_LI850","CellTemp_LI850","CellPres_LI850"
                                     ),
                                     selected = c("CH4", "CO2_LI850")
                  ), width = 3
              ),
              mainPanel(
                plotlyOutput("plot_flux",
                             width = "70vw", height = "70vh")
              )
            )
    ),
    nav_panel("Rad7",
              sidebarLayout(
                sidebarPanel(
                  h3("Date Range"),
                  dateInput("rad7_start_date", "Start date"),
                  dateInput("rad7_end_date", "End date"),
                  h3("Variables:"),
                  checkboxGroupInput("rad7_vars", label=NULL,
                                     choices = c(
                                       "Relative_humidity_pct", "Radon_Bqm3", "Radon_error_Bqm3"
                                     ),
                                     selected = c("Radon_Bqm3", "Radon_error_Bqm3")
                  ), width = 3
                ),
                mainPanel(
                  plotlyOutput("plot_rad7",
                               width = "70vw", height = "70vh")
                )
              )
    )
  )
)

server <- function(input, output, session) {
  # Grab data
  exo <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/create-yaml/Data/Processed/KARBON_EXO.csv")
  flux <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/create-yaml/Data/Processed/KARBON_FLUX.csv")
  adcp <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/create-yaml/Data/Processed/KARBON_HYDROLOGY.csv")
  rad7 <- read_csv("https://raw.githubusercontent.com/VCU-Rice-Rivers-Center/KARBON-LateralFlux/refs/heads/create-yaml/Data/Processed/KARBON_RADON.csv")
  

  min_date <- min(c(exo$TIMESTAMP, flux$TIMESTAMP, adcp$TIMESTAMP, rad7$TIMESTAMP), na.rm = TRUE) %>% as_date()
  max_date <- max(c(exo$TIMESTAMP, flux$TIMESTAMP, adcp$TIMESTAMP, rad7$TIMESTAMP), na.rm = TRUE) %>% as_date()
  
  # Set initial values for all date inputs across all tabs
  tabs <- c("exo", "adcp", "flux", "rad7")
  for (tab in tabs) {
    updateDateInput(session, paste0(tab, "_start_date"), value = max_date - days(7), min = min_date, max = Sys.Date())
    updateDateInput(session, paste0(tab, "_end_date"), value = max_date, min = min_date, max = Sys.Date())
  }
  
  # Synchronize start dates across all tabs when any start date changes
  lapply(tabs, function(tab) {
    observeEvent(input[[paste0(tab, "_start_date")]], {
      new_start <- input[[paste0(tab, "_start_date")]]
      for (target in setdiff(tabs, tab)) {
        if (!is.null(input[[paste0(target, "_start_date")]]) && 
            input[[paste0(target, "_start_date")]] != new_start) {
          updateDateInput(session, paste0(target, "_start_date"), value = new_start)
        }
      }
    }, ignoreInit = TRUE)
  })
  
  # Synchronize end dates across all tabs when any end date changes
  lapply(tabs, function(tab) {
    observeEvent(input[[paste0(tab, "_end_date")]], {
      new_end <- input[[paste0(tab, "_end_date")]]
      for (target in setdiff(tabs, tab)) {
        if (!is.null(input[[paste0(target, "_end_date")]]) && 
            input[[paste0(target, "_end_date")]] != new_end) {
          updateDateInput(session, paste0(target, "_end_date"), value = new_end)
        }
      }
    }, ignoreInit = TRUE)
  })
  
  # Most recent TIMESTAMP per instrument: 
  exo_ts <- max(exo$TIMESTAMP)
  flux_ts <- max(flux$TIMESTAMP)
  adcp_ts <- max(adcp$TIMESTAMP)
  rad7_ts <- max(rad7$TIMESTAMP)
  
  output$overview <- renderUI({
    
    formatted_text <- paste(
      "<div><h2>Latest Data</h2></br>
      <ul>
      <li><b>Exo2 Water Quality Sonde:</b> ",
      format(exo_ts), "</li>
      <li><b>LI-850 and LI-7810 Gas Analyzers:</b> ",
      format(flux_ts), "</li>
      <li><b>Sontek ADCP Sensor:</b> ",
      format(adcp_ts), "</li>
      <li><b>Durridge Rad7 Radon Detector:</b> ",
      format(rad7_ts), "</li></ul>
      <img src = 'images/KimagesCreekDock.jpg'/></div>"
    )
    
    HTML(formatted_text)
  })
  
  output$plot_flux <- renderPlotly({
    make_plot(flux, input$flux_vars, input$exo_start_date, input$exo_end_date)
  })
  
  output$plot_rad7 <- renderPlotly({
    make_plot(rad7, input$rad7_vars, input$exo_start_date, input$exo_end_date)
  })
  
  output$plot_adcp <- renderPlotly({
    make_plot(adcp, input$adcp_vars, input$exo_start_date, input$exo_end_date)
  })
  
  output$plot_exo <- renderPlotly({
    make_plot(exo, input$exo_vars, input$exo_start_date, input$exo_end_date)
  })
  
}

shinyApp(ui, server)
