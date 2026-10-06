# LoggerNet Task Master with Python 

### 1. General Information
Our LoggerNet PC collects data on a schedule and stores it locally. This data needs to be
pushed to a cloud service frequently so that it can be accessed by all users of the project without
manual intervention. Another benefit of this pipeline is to have near real-time data reporting capabilities,
allowing for quick checks of current conditions. 

### 2. File Overview

* **LoggerNet_TaskMaster_Current_GDrive.py**: Reads LoggerNet output tables and pushes data to GDrive *Current* folder. It
does so by looking at the LoggerNet output tables and appending new lines of data. This script will be used within LoggerNet 
Task Master to run on an hourly basis. 

* **LoggerNet_TaskMaster_Archive_GDrive.py**: Copies the contents of the GDrive *Current* folder to the GDrive *Archive* folder.
Copied files are timestamped with the msot recent entry's timestamp. After copying the data, the *Current* data files are 
emptied. This script will also but used within LoggerNet Task Master to run on a bi-monthly basis, occurring on the 1st and
15th of each month. 

### 3. Notes

For these scripts to run on the LoggerNet PC, Google Drive for desktop needs to be installed so that the files can be
written to the Google Drive folder location. 

There will need to be separate files for the different output tables. For KARBON, this will be separate files for the 
EXO, ADCP, Rad7, and LI-COR data tables. 

Will need to consider the timing of these schedules when implementing: 

* Program Execution Interval: The datalogger scan rate determines how often the datalogger carries out instructions in 
the datalogger program.

* Table Storage Interval: Different data tables are set up to store data records at regular intervals. For example our
LI-COR table stores data at 10 sec intervals wheras the Rad7 table stores records at 15 minute intervals. 

* LoggerNet Data Collection Interval: This specifies the interval that the LoggerNet server requests new data from the 
datalogger. If the collection interval is faster than the rate at which data is being stored to a data table by the
data logger program, data will not be collected every call, but only at intervals when new data is available. 

* Task Master Hourly Update: We can decide the frequency that the Current data python script runs. We will want to stagger
this after the LoggerNet Data Collection Interval. 

* Task Master Bi-monthly Update: This will run on the 1st and 15th of the month. We should stagger the run after the last
hourly update that occurs before the 1st and 15th of each month. 


