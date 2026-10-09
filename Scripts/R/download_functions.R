
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
                              search_term = "LateralFlux") {
  
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
  
  # Create list of dates within specified range
  possible_file_names <- format(
    seq.Date(start_date, Sys.Date(), by = "1 day"),
    "%Y%m%d"
  )
  
  # Subset archive files to files created within specified date range
  relevant_files <- archive_files[grepl(paste0(possible_file_names, collapse="|"), archive_files$name), ]
  
  # Do not include NowConstTable
  relevant_files <- relevant_files[!grepl("NewConstTable", relevant_files$name), ]
  
  if (nrow(relevant_files) > 0) {
    # Extract modified time variable from GDrive API
    relevant_files <- relevant_files %>%
      mutate(label = map(drive_resource, names)) %>%
      unnest(c(drive_resource, label)) %>%
      filter(label == "modifiedTime") %>%
      select(name, id, drive_resource) %>%
      rename(modifiedTime = drive_resource) %>%
      mutate(modifiedTime = as_datetime(unlist(modifiedTime), format = "%Y-%m-%dT%H:%M:%OSZ")) # Google Drive API Datetime is in RFC3339 format.
    
    # Remove files that are already loaded and haven't been modified
    already_loaded <- list.files(local_folder)
    
    # See when local files were last modified
    loaded_file_info <- file.info(list.files(local_folder, full.names = T)) %>%
      mutate(name = basename(row.names(.))) %>%
      select(name, mtime)
    
    # Identify files in Google Drive that have been modified since last local download
    modified <- relevant_files %>%
      select(name, modifiedTime) %>%
      left_join(loaded_file_info, by = "name") %>%
      filter(modifiedTime > mtime)
    
    # Only process files that are new or have been modified in Google Drive
    relevant_files <- relevant_files %>%
      filter(!name %in% already_loaded | name %in% modified$name)
  }
  
  # Load data in the current folder every time (as these files are constantly scheduling updates)
  message("Downloading Current Data")
  current_ids <- current_files$id
  current_names <- current_files$name
  map2(current_ids, current_names, 
       \(x, y) drive_download(
         file = x,
         path = file.path(local_folder, y),
         overwrite = TRUE
       ))

  # Download data from archive folder if relevant:
  if (nrow(relevant_files) == 0) {
    message("No new files in archive folder to download")
  } else {
    message("Downloading ", nrow(relevant_files), " files")
    relevant_ids <- relevant_files$id
    relevant_names <- relevant_files$name
    map2(relevant_ids, relevant_names, 
         \(x, y) drive_download(
           file = x,
           path = file.path(local_folder, y),
           overwrite = TRUE
         ))
  }
}



