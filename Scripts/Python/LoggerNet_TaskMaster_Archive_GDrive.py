import os
from datetime import datetime

CURRENT_PATH = "G:/Shared drives/CHS-RRC Data/LateralFlux/Data/Current/"
ARCHIVE_PATH = "G:/Shared drives/CHS-RRC Data/LateralFlux/Data/Archive/"
ARCHIVE_EXT = ".dat"
STATE_PATH = "C:/Users/wicklk/Documents/Lateral Flux"
DATETIME_FMT = "%Y-%m-%d %H:%M:%S"
ARCHIVE_DT_FMT = "%Y%m%d%H%M%S"

# File Names
exo = "LateralFlux_CR1000Xe_ExoTable"
flux = "LateralFlux_CR1000Xe_FLUX_7810"
rad7 = "LateralFlux_CR1000Xe_Rad7Table"
adcp = "LateralFlux_CR1000Xe_SontekTable"

# State File by Sensor
exo_state = "state_exo.txt"
flux_state = "state_flux.txt"
rad7_state = "state_rad7.txt"
adcp_state = "state_adcp.txt"

def archive_update(current_filename, local_state_filename):
    
    local_state_file = os.path.join(STATE_PATH, local_state_filename).replace("\\","/")
    current_file = CURRENT_PATH + current_filename + ARCHIVE_EXT

    headers_to_copy = []
    lines_to_append = []
    current_lines_to_append = []

    archive_ts = datetime.min

    if os.path.exists(local_state_file):
        with open(local_state_file, "r") as f:
            val = f.read().strip()
            if val:
                archive_ts = datetime.strptime(val, DATETIME_FMT)
                archive_ts_fmt = archive_ts.strftime(ARCHIVE_DT_FMT)

    new_max_ts = archive_ts

    if os.path.exists(current_file):
        with open(current_file, "r") as f:
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
                    if row_ts <= archive_ts:
                        lines_to_append.append(line)
                    if row_ts > archive_ts:
                        current_lines_to_append.append(line)
                        new_max_ts = row_ts
                except ValueError:
                    continue

        if lines_to_append:
            ARCHIVE_FILE_FINAL = ARCHIVE_PATH + current_filename + archive_ts_fmt + ARCHIVE_EXT

            archive_exists = os.path.exists(ARCHIVE_FILE_FINAL)

            with open(ARCHIVE_FILE_FINAL, "a") as dst:
                if not archive_exists:
                    dst.writelines(headers_to_copy)
                    dst.writelines(lines_to_append)

    if not current_lines_to_append:
        os.remove(current_file)

    if current_lines_to_append:
        with open(current_file, "w") as dst:
            dst.writelines(headers_to_copy)
            dst.writelines(current_lines_to_append)

        with open(local_state_file, "w") as f:
            f.write(new_max_ts.strftime(DATETIME_FMT))
        
archive_update(exo, exo_state)
archive_update(flux, flux_state)
archive_update(rad7, rad7_state)
archive_update(adcp, adcp_state)