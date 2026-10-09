### Packages and Source
source(here("Scripts", "R", "download_functions.R"))

library(tidyverse)
library(googledrive)
library(here)

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

### Access Folder Contents

# Connect to Lateral Flux data folder
current_id <- as_id("1NT-9tnjc82k19ECxz_SgPVQLNH0PeszL")
archive_id <- as_id("1Pakk0VjLoAyew-wrzz6GLtXeMabrMAwN")

# Specify the local path where you want to save the folder
local_folder <- here("Data", "Raw")

# Start the recursive download
download_folder(current_id, local_folder)


