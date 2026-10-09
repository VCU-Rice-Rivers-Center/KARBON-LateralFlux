
#############################################
### Functions for Downloading GDrive Data ###
#############################################


#' Download all items in a Google Drive folder
#' Source: https://stackoverflow.com/questions/64687627/download-all-files-and-subdirectories-from-a-google-drive-directory-from-r
#'
#' @param folder_id string - the Google Drive folder ID
#' @param local_path string - the local file path (not including file name) where the files will be downloaded
#'
#' @returns NULL 
#' @export
#'
#' @examples
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

#' Read Data TOA5 data and store as dataframe
#' Source: https://github.com/wilsonsj100/serc-lateral-flux/blob/dashboard/R/load_data.R
#'
#' @param file string - file path and name of file to be read. TOA5 format because of header requirements
#'
#' @returns dataframe 
#' @export
#'
#' @examples
read_data <- function(file) {
  col_names <- colnames(read_delim(
    file,
    delim = ",",
    skip = 1,
    show_col_types = FALSE,
    n_max = 1
  ))
  
  data <- read_csv(
    file, 
    skip = 4,
    show_col_types = FALSE,
    col_names = col_names
  )
  
  return(data)
}

download_new_data <- function(local_folder = here("Data", "Raw"), 
                              start_date = Sys.Date() - days(100),
                              current_folder = "1NT-9tnjc82k19ECxz_SgPVQLNH0PeszL",
                              archive_folder = "1Pakk0VjLoAyew-wrzz6GLtXeMabrMAwN",
                              search_term = "LateralFlux_CR1000Xe_") {
  
  # Identify all files in Google Drive
  message("Looking for new data files on Google Drive")
  
  # Grab files from archive folder that match search term
  archive_files <- drive_ls(as_id(archive_folder)) %>%
    filter(grepl(search_term, name))
  
  # Grab non-backup files from current folder that match search term
  current_files <- drive_ls(as_id(current_folder)) %>%
    filter(
      grepl(search_term, name), 
      !grepl("backup", name)
    )
  
  # 
  possible_file_names <- format(
    seq.Date(start_date, Sys.Date(), by = "1 day"),
    "%Y%m%d"
  )
  
  print(possible_file_names)
  
  
}



