# Processing with R

### 1. General Information

R code in this folder will handle pulling data from the Google Drive via the Google Drive API for pre-processing, so that
the data can be used in a near real-time data dashboard. Will be trying to model this pipeline after the 
[serc-lateral-flux](https://github.com/wilsonsj100/serc-lateral-flux/tree/dashboard) workflow.

### 2. File Overview

* **process_data.R** - This function will be called in the yaml file to trigger automatic data downloads from Google Drive and processing of data
to smaller files for R shiny dashboard. It completes google drive authentication, runs code to download raw data, and finally runs code to process raw data
and store it as CSVs. 

* **download_functions.R** - This contains the helper functions for downloading data that are referenced in process_data.R

* **processing_functions.R** - This contains the helper functions for processing data that are referenced in process_data.R

### 3. Notes




