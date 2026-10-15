
############################################
### Functions for Processing Data Tables ###
############################################

#' Process Raw Data and Store to CSV
#' Modified from: https://github.com/wilsonsj100/serc-lateral-flux/blob/dashboard/R/generate_dashboard_outputs.R
#'
#' @param days_to_include integer - number of days to be included in the final outputs
#'
#' @returns NULL - but writes several dfs to CSVs
#' @export
#'
#' @examples
process_raw_data <- function(days_to_include = 100) {
  
  # List files in the local folder
  files <- list.files(here("Data", "Raw"), full.names = T)
  
  # Group by sensor
  files_exo <- files[grepl("Exo", files)]
  files_rad7 <- files[grepl("Rad7", files)]
  files_sontek <- files[grepl("Sontek", files)]
  files_flux <- files[grepl("FLUX", files)] 
  
  TIMEZONE <- "EST" # Used across all
  
  # Select columns for dashboard
  exo_cols <- c(
    "DO_mgL", "FDOM_RFU", "Chlorophyll_ugL", "Conductivity",
    "DO_saturation", "Salinity_PPT", "TDS_mgL", "pH", "Temp_C",
    "Depth_m"
  )
  
  sontek_cols <- c(
    "Water_depth_m", "Flowrate_ms", "Index_velocity_ms",
    "Mean_velocity_ms"
  )
  
  flux_cols <- c(
    "H2O_7810", "CH4_7810", "CellTemp_7810", "CellPres_7810",
    "CO2_850","H2O_850","CellTemp_850","CellPres_850"
  )
  
  rad7_cols <- c("Relative_humidity_pct", "Radon_Bqm3", "Radon_error_Bqm3")
  
  # Process data
  data_exo <- files_exo %>%
    map(read_data) %>%
    bind_rows() %>%
    mutate(
      TIMESTAMP = paste(format(TIMESTAMP, "%Y-%m-%d %H:%M:%S")),
      TIMESTAMP = ymd_hms(TIMESTAMP, tz = TIMEZONE)
    ) %>%
    rename(
      DO_mgL = ODO_MgL,
      DO_saturation = ODO_sat, 
      TDS_mgL = TDS_mg_L
    ) %>%
    select(all_of(c("TIMESTAMP", exo_cols))) %>%
    filter(as.Date(TIMESTAMP) > Sys.Date() - days(days_to_include))
  
  data_sontek <- files_sontek %>%
    map(read_data) %>%
    bind_rows() %>%
    mutate(
      TIMESTAMP = paste(format(TIMESTAMP, "%Y-%m-%d %H:%M:%S")),
      TIMESTAMP = ymd_hms(TIMESTAMP, tz = TIMEZONE)
    ) %>%
    rename(
      Water_depth_m = Water_depth,
      Index_velocity_ms = Index_velocity,
      Mean_velocity_ms = Mean_velocity,
      Flowrate_ms = Flowrate
    ) %>%
    select(all_of(c("TIMESTAMP", sontek_cols))) %>%
    filter(as.Date(TIMESTAMP) > Sys.Date() - days(days_to_include))
  
  data_rad7 <- files_rad7 %>%
    map(read_data) %>%
    bind_rows() %>%
    mutate(
      TIMESTAMP = paste(format(TIMESTAMP, "%Y-%m-%d %H:%M:%S")),
      TIMESTAMP = ymd_hms(TIMESTAMP, tz = TIMEZONE)
    ) %>%
    rename(
      Relative_humidity_pct = RH_sample_Rad7,
      Radon_Bqm3 = Radon_concentration_Rad7,
      Radon_error_Bqm3 = Radon_concentration_uncertainty_Rad7
    ) %>%
    select(all_of(c("TIMESTAMP", rad7_cols))) %>%
    filter(as.Date(TIMESTAMP) > Sys.Date() - days(days_to_include))
  
  data_flux <- files_flux %>%
    map(read_data) %>%
    bind_rows() %>%
    mutate(
      TIMESTAMP = paste(format(TIMESTAMP, "%Y-%m-%d %H:%M:%S")),
      TIMESTAMP = ymd_hms(TIMESTAMP, tz = TIMEZONE)
    ) %>%
    rename(
      H2O_7810 = H2O,
      CH4_7810 = CH4,
      CellPres_7810 = cavity_p, 
      CellTemp_7810 = cavity_t,
      CO2_850 = CO2_LI850,
      H2O_850 = H2O_LI850,
      CellTemp_850 = CellTemp_LI850,
      CellPres_850 = CellPres_LI850
    )
    select(all_of(c("TIMESTAMP", flux_cols))) %>%
    filter(as.Date(TIMESTAMP) > Sys.Date() - days(days_to_include))
  
  # Output
  write.csv(data_exo,
            here("Data","Processed", "KARBON_EXO.csv"),
            row.names = FALSE
  )
  
  write.csv(data_rad7,
            here("Data","Processed", "KARBON_RADON.csv"),
            row.names = FALSE
  )
  
  write.csv(data_sontek,
            here("Data","Processed", "KARBON_HYDROLOGY.csv"),
            row.names = FALSE
  )
  
  write.csv(data_flux,
            here("Data","Processed", "KARBON_FLUX.csv"),
            row.names = FALSE
  )
}
