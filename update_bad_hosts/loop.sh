#!/bin/bash

TMP_PATH="/tmp"
NAME=$(basename "$0")

# give a 5 minute wait until first run after boot
sleep 300

while [ 5 -gt 4 ]; do
 # add date and time to log
 dateStr=$(date +"%Y/%m/%d %H:%M")
 printf "%-30s %s\n" "[$NAME]" "$dateStr"

 # perform update
 ./update_bad_hosts.sh

 # run daily
 sleep 86400
done
