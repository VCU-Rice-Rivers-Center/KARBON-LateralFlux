# CRBasic Program

### 1. General Information
The CRBasic Program controls which instruments are measured, the frequency at which they are measured, and how often these
data are stored into data logger memory. 

The CRBasic Program for KARBON measures data from a LICOR LI-7810, LICOR LI-850, Durridge Rad7 Radon Detector, YSI Exo2 Sonde,
and Sontek ADCP IQ Series. 

* Data for the gas analyzers LI-850 and LI-7810 are scanned at a 10 second interval with their data being stored in a data table
every 10 seconds as well. 

* Data for the other 3 instruments are scanned at a 1 minute interval, with their data being averaged and stored into tables 
at different intervals:
  * **Rad7**: 15 minutes
  * **ADCP**: 3 minutes
  * **Exo2**: 6 minutes

### 2. File Overview

* **FloatingDock_LateralFlux_CR1000Xe_v01.CR1X**: The current CRBasic file used to program the data logger. It's already had
a few iterations that have been managed in a Google Drive, but moving forwards this document will be updated in GitHub. 

### 3. Change Log

For more detailed changes, view commit history. This list covers big changes that may be useful for future troubleshooting:

* *2026-10-07*: Fixing serial buffer unsynchronization with the LI-850. After a few hours of running, the LI-850 stopped sending
the entire data string via RS-232. This was caused by a slow accumulation of leftover bytes in the serial buffer for ComC1 which caused
improper mapping of the LI-850 variables via the `SplitStr` CRBasic function. This was solved by adding a `SerialFlush(ComC1)` command
to clear the buffer after the serial data is read. 

* *2026-10-07*: CellTemp LI-850 data table variable NAN. This was caused by the past `SplitStr` function which skipped over the first
element of the string because it was not preceeded with the delimiter in our function (" "). Updating the function from 
`SplitStr(LI850(1), DATA_string850, " ", 4, 4)` to `SplitStr(LI850(1), DATA_string850, " ", 4, 0)` resolved the issue.

