import os
from datetime import datetime

DAT_FILE = "C:/Users/wicklk/Documents/Lateral Flux/GDriveTest.dat" # Path to default LoggerNet output tables
CURRENT_FILE = "G:/Shared drives/CHS-RRC Data/LateralFlux/Current/current_data.dat" # Path to GDrive Current data folder
STATE_FILE = "C:/Users/wicklk/Documents/Lateral Flux/last_timestamp.txt" # Path to last timestamp file - used to query next file update
DATETIME_FMT = "%Y-%m-%d %H:%M:%S"

# Initialize timestamp var
last_ts = datetime.min

# Check if we have a timestamp saved in our state file
if os.path.exists(STATE_FILE):
    with open(STATE_FILE, "r") as f:
        val = f.read().strip()
        if val:
            last_ts = datetime.strptime(val, DATETIME_FMT)

new_max_ts = last_ts
lines_to_append = []
headers_to_copy = []

if os.path.exists(DAT_FILE):
    with open(DAT_FILE, "r") as f:
        # Account for header lines
        for _ in range(4):
            headers_to_copy.append(f.readline())

        # Stream remaining data lines
        for line in f:
            if not line.strip():
                continue

            # Extract timestamp column (always first field in TOA5)
            first_field = line.split(",")[0].strip('"')
            try:
                row_ts = datetime.strptime(first_field, DATETIME_FMT)
                if row_ts > last_ts:
                    lines_to_append.append(line)
                    if row_ts > new_max_ts:
                        new_max_ts = row_ts
            except ValueError:
                continue

    # Write new records to current file
    if lines_to_append:
        current_exists = os.path.exists(CURRENT_FILE)

        with open(CURRENT_FILE, "a") as dst:
            if not current_exists:
                dst.writelines(headers_to_copy)
            dst.writelines(lines_to_append)

        with open(STATE_FILE, "w") as f:
            f.write(new_max_ts.strftime(DATETIME_FMT))
