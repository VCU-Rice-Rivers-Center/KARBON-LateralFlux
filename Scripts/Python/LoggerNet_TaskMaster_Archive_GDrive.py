import os
from datetime import datetime

CURRENT_FILE = "G:/Shared drives/CHS-RRC Data/LateralFlux/Current/current_data.dat"
ARCHIVE_FILE = "G:/Shared drives/CHS-RRC Data/LateralFlux/Archive/archive_data"
ARCHIVE_EXT = ".dat"
STATE_FILE = "C:/Users/wicklk/Documents/Lateral Flux/last_timestamp.txt"
DATETIME_FMT = "%Y-%m-%d %H:%M:%S"
ARCHIVE_DT_FMT = "%Y%m%d%H%M%S"

headers_to_copy = []
lines_to_append = []
current_lines_to_append = []

archive_ts = datetime.min

if os.path.exists(STATE_FILE):
    with open(STATE_FILE, "r") as f:
        val = f.read().strip()
        if val:
            archive_ts = datetime.strptime(val, DATETIME_FMT)
            archive_ts_fmt = archive_ts.strftime(ARCHIVE_DT_FMT)

new_max_ts = archive_ts

if os.path.exists(CURRENT_FILE):
    with open(CURRENT_FILE, "r") as f:
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
        ARCHIVE_FILE_FINAL = ARCHIVE_FILE + archive_ts_fmt + ARCHIVE_EXT

        archive_exists = os.path.exists(ARCHIVE_FILE_FINAL)

        with open(ARCHIVE_FILE_FINAL, "a") as dst:
            if not archive_exists:
                dst.writelines(headers_to_copy)
                dst.writelines(lines_to_append)

if not current_lines_to_append:
    os.remove(CURRENT_FILE)

if current_lines_to_append:
    with open(CURRENT_FILE, "w") as dst:
        dst.writelines(headers_to_copy)
        dst.writelines(current_lines_to_append)

    with open(STATE_FILE, "w") as f:
        f.write(new_max_ts.strftime(DATETIME_FMT))
        
