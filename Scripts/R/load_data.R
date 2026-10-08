library(readr)

# Loading data

load_data <- function(file) {
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


