#!/bin/bash

# set -euo pipefail
IFS=$'\n\t'

usage() { echo "Usage: sql_data_init.sh -s <SQL Server FQDN> -u <sql username> -p <sql password> " 1>&2; exit 1; }

bcp Devices out ~/Devices_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp factMLOutputData out ~/factMLOutputData_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp IOTHubDatas out ~/IOTHubDatas_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp POIs out ~/POIs_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp TripPoints out ~/TripPoints_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp Trips out ~/Trips_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp UserProfiles out ~/UserProfiles_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp POISource out ~/POISource_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
bcp TripPointSource out ~/TripPointSource_export.txt -S teamdef93sql.database.windows.net -U teamdef93sa -P 2J2fn9Tl3pwd -d mydrivingDB -c -t ','
