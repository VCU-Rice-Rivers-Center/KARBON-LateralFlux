### Packages 

library(dplyr)
library(tidyr)
library(lubridate)
library(googledrive)

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

### Read Files

# Define the recursive download function (from https://stackoverflow.com/questions/64687627/download-all-files-and-subdirectories-from-a-google-drive-directory-from-r)
download_folder <- function(folder_id, local_path) {
  # Create the local directory if it doesn't exist
  dir.create(local_path, showWarnings = FALSE, recursive = TRUE)
  
  # List all items in the folder
  items <- drive_ls(as_id(folder_id))
  
  # Loop through each item
  for (i in seq_len(nrow(items))) {
    item <- items[i, ]
    
    # Check if the item is a folder
    if (item$drive_resource[[1]]$mimeType == "application/vnd.google-apps.folder") {
      # If it's a folder, recursively download its contents
      subfolder_local_path <- file.path(local_path, item$name)
      download_folder(item$id, subfolder_local_path)
      ###
      # the magic is here, it recalls the self-defined function again
      ###
    } else {
      # If it's a file, download it to the local path
      cat(sprintf("Downloading file: %s\n", file.path(local_path, item$name)))
      drive_download(
        file = item,
        path = file.path(local_path, item$name),
        overwrite = TRUE
      )
    }
  }
}

# Specify the local path where you want to save the folder
local_folder <- "Data/Raw/"

# Start the recursive download
download_folder(current_id, local_folder)


