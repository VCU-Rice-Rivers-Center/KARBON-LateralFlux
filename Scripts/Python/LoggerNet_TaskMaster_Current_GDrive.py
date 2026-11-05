import os
from datetime import datetime

# Tuneables:

DAT_PATH = "C:/Campbellsci/PC400" # Path to default LoggerNet output tables
CURRENT_PATH = "G:/Shared drives/CHS-RRC Data/LateralFlux/Data/Current" # Path to GDrive Current data folder
STATE_PATH = "C:/Users/wicklk/Documents/Lateral Flux" # Path to last timestamp file - used to query next file update
DATETIME_FMT = "%Y-%m-%d %H:%M:%S"

# File Names
exo = "LateralFlux_CR1000Xe_ExoTable.dat"
flux = "LateralFlux_CR1000Xe_FLUX_7810.dat"
rad7 = "LateralFlux_CR1000Xe_Rad7Table.dat"
adcp = "LateralFlux_CR1000Xe_SontekTable.dat"

# State File by Sensor
exo_state = "state_exo.txt"
flux_state = "state_flux.txt"
rad7_state = "state_rad7.txt"
adcp_state = "state_adcp.txt"

def current_update(local_dat_filename, local_state_filename):

    local_dat_file = os.path.join(DAT_PATH, local_dat_filename).replace("\\","/")
    local_state_file = os.path.join(STATE_PATH, local_state_filename).replace("\\","/")
    upload_file = os.path.join(CURRENT_PATH, local_dat_filename).replace("\\","/")

    # Initialize timestamp var
    last_ts = datetime.min

    # Check if we have a timestamp saved in our state file
    if os.path.exists(local_state_file):
        with open(local_state_file, "r") as f:
            val = f.read().strip()
            if val:
                last_ts = datetime.strptime(val, DATETIME_FMT)

    new_max_ts = last_ts
    lines_to_append = []
    headers_to_copy = []

    if os.path.exists(local_dat_file):
        with open(local_dat_file, "r") as f:
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
            current_exists = os.path.exists(upload_file)

            with open(upload_file, "a") as dst:
                if not current_exists:
                    dst.writelines(headers_to_copy)
                dst.writelines(lines_to_append)

            with open(local_state_file, "w") as f:
                f.write(new_max_ts.strftime(DATETIME_FMT))

current_update(exo, exo_state)
current_update(flux, flux_state)
current_update(rad7, rad7_state)
current_update(adcp, adcp_state)