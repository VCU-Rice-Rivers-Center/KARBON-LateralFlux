### Packages and Source
library(tidyverse)
library(googledrive)
library(here)

source(here("Scripts", "R", "download_functions.R"))
source(here("Scripts", "R", "processing_functions.R"))

### Authentication 

# Fetch the key from the system environment (if running an action from GitHub)
gcp_key <- Sys.getenv("GCP_SA_KEY")

# If running locally, authenticate via browser
if (nzchar(gcp_key)) {
  drive_auth(path = gcp_key)
  message("Authenticated using GCP Service Account Secret")
} else {
  drive_auth()
  message("Authenticated via browser")
}

### Download new data
download_new_data(
  local_folder = here("Data", "Raw"), 
  start_date = Sys.Date() - days(100),
  current_folder = "1NT-9tnjc82k19ECxz_SgPVQLNH0PeszL",
  archive_folder = "1Pakk0VjLoAyew-wrzz6GLtXeMabrMAwN",
  search_term = "LateralFlux_CR1000Xe"
  )

### Process raw data and store to Processed folder
process_raw_data(
  days_to_include = 100
)

