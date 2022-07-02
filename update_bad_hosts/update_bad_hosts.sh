#!/bin/bash

TMP_PATH="/tmp"
NAME=$(basename "$0")

# clean up any leftovers from last run and download list of bad hosts
if [ -e "$TMP_PATH/download_bad_hosts.out" ]; then
 rm "$TMP_PATH/download_bad_hosts.out"
fi
./download_bad_hosts.sh

# "$TMP_PATH/download_bad_hosts.out" wont exist if download failed
if [ -e "$TMP_PATH/download_bad_hosts.out" ]; then

 # see if current list of bad hosts is different from new lift of bad hosts, only update /etc/hosts if new list if different
 go=0
 if [ -e /etc/custom_scripts/current ]; then
  printf "%-30s %s\n" "[$NAME]" "wget successful. Comparing downloaded list to local version."
  md5A=$(md5sum --tag /etc/update_bad_hosts/current | cut -d = -f 2 | tr -d " ")
  md5B=$(md5sum --tag "$TMP_PATH/download_bad_hosts.out" | cut -d = -f 2 | tr -d " ")
  if [ "$md5A" != "$md5B" ]; then
   go=1
  fi
 else
  go=1
 fi

 # update /etc/hosts
 if [ $go -eq 1 ]; then
  printf "%-30s %s\n" "[$NAME]" " Updating blocklist with newer version."
  # make copy of /etc/hosts with old bad host list stripped out
  sed '/## BAD HOSTS START ##/,/## BAD HOSTS END ##/d' /etc/hosts > "$TMP_PATH/update_bad_hosts.out"
  ## add new list of bad hosts to copy of /etc/hosts
  echo "## BAD HOSTS START ##" >> "$TMP_PATH/update_bad_hosts.out"
  cat "$TMP_PATH/download_bad_hosts.out" >> "$TMP_PATH/update_bad_hosts.out"
  echo "## BAD HOSTS END ##" >> "$TMP_PATH/update_bad_hosts.out"
  # replace /etc/hosts 
  cat "$TMP_PATH/update_bad_hosts.out" > /etc/hosts
  # save a copy of bad hosts list for next run to compare to
  cp "$TMP_PATH/download_bad_hosts.out" /etc/update_bad_hosts/current
 else
  printf "%-30s %s\n" "[$NAME]" " No update to current blocklist needed."
 fi
 # clean up
 rm "$TMP_PATH/download_bad_hosts.out"

 printf "%-30s %s\n" "[$NAME]" "Operation completed."
 exit 0

else
 printf "%-30s %s\n" "[$NAME]" "Download failed. Aborting."
 exit 1
fi

exit 1
