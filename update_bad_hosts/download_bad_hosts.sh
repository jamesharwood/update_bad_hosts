#!/bin/bash

TMP_PATH="/tmp"
NAME=$(basename "$0")

# clean up from last run
if [ -e "$TMP_PATH/download_bad_hosts.tmp1" ]; then
 rm "$TMP_PATH/download_bad_hosts.tmp1"
fi

# download each list and append to tmp file
printf "%-30s %s\n" "[$NAME]" "Downloading blocklists ..."
dl_ok=0
dl_lines=0
while read -r line; do
 if [ -n "$line" ]; then
  let "dl_lines=dl_lines+1"
  printf "%-30s %s\n" "[$NAME]" " $line ..."
  if [ -e "$TMP_PATH/download_bad_hosts.tmp0" ]; then
   rm "$TMP_PATH/download_bad_hosts.tmp0"
  fi
  # either wget for http address or cat for local file
  isFile=$(echo "$line" | awk '{print substr($0,0,7)}' | grep -c "file://")
  if [ $isFile -lt 1 ]; then
   wget -q "$line" -O "$TMP_PATH/download_bad_hosts.tmp0"
  else
   inFilename=$(echo "$line" | cut -c8-)
   if [ -e "$inFilename" ]; then
    cat "$inFilename" > "$TMP_PATH/download_bad_hosts.tmp0"
   fi
  fi
  # check if download worked
  if [ $? -eq 0 ]; then
   if [ -e "$TMP_PATH/download_bad_hosts.tmp0" ]; then
    let "dl_ok=dl_ok+1"
    # change 127.0.0.1 to 0.0.0.0
    sed -i -e 's/127.0.0.1/0.0.0.0/g' "$TMP_PATH/download_bad_hosts.tmp0"
    # remove comment lines
    sed -i 's:^\s*#.*$::g' "$TMP_PATH/download_bad_hosts.tmp0"
    sed -i '/^[[:blank:]]*$/ d' "$TMP_PATH/download_bad_hosts.tmp0"
    # add to main work file
    cat "$TMP_PATH/download_bad_hosts.tmp0" >> "$TMP_PATH/download_bad_hosts.tmp1"
    rm "$TMP_PATH/download_bad_hosts.tmp0"
   else
    printf "%-30s %s\n" "[$NAME]" "  FAILED"
   fi
  else
   printf "%-30s %s\n" "[$NAME]" "  FAILED"
  fi
 fi
done < list-blocklists.txt
if [ $dl_ok -ne $dl_lines ]; then
 dl_ok=0
fi

# only produce output file if all lines downloaded ok
if [ $dl_ok -gt 0 ]; then

 # remove duplicates
 printf "%-30s %s\n" "[$NAME]" "Removing duplicate entries ..."
 sort -u "$TMP_PATH/download_bad_hosts.tmp1" > "$TMP_PATH/download_bad_hosts.tmp2"
 numLinesOri=$(wc -l "$TMP_PATH/download_bad_hosts.tmp1" | cut -d " " -f 1)
 rm "$TMP_PATH/download_bad_hosts.tmp1"
 numLinesAfterDup=$(wc -l "$TMP_PATH/download_bad_hosts.tmp2" | cut -d " " -f 1)
 let "linesRemoved=numLinesOri-numLinesAfterDup"
 printf "%-30s %s\n" "[$NAME]" " $linesRemoved duplicates removed."

 # check for non empty ip adresses in hosts (ie. suspicious)
 printf "%-30s %s\n" "[$NAME]" "Removing any entries that do not point to localhost ..."
 if [ -e "$TMP_PATH/download_bad_hosts.out" ]; then
  rm "$TMP_PATH/download_bad_hosts.out"
 fi
 awk -F ' ' '{if($1=="0.0.0.0" || $1=="::"){print $1" "$2}}' "$TMP_PATH/download_bad_hosts.tmp2" > "$TMP_PATH/download_bad_hosts.tmp3"
 # print out removed lines to log
 awk -F ' ' '{if($1!="0.0.0.0" && $1!="::"){printf "%-30s  %s %s\n", "[download_bad_hosts.sh]", $1 , $2}}' "$TMP_PATH/download_bad_hosts.tmp2"
 # remove entries where localhost address in hostname field (ie malformed lines)
 awk -F ' ' '{if($2!="0.0.0.0" && $2!="::"){print $1" "$2}}' "$TMP_PATH/download_bad_hosts.tmp3" > "$TMP_PATH/download_bad_hosts.tmp4"
 # remove whitelisted hosts from block list
 printf "%-30s %s\n" "[$NAME]" "Removing any whitelisted entries ..."
 cat whitelist.txt | while read line || [[ -n $line ]]; do
  if [ -n "$line" ]; then
   printf "%-30s %s\n" "[$NAME]" " $line"
   awk "!/$line/" "$TMP_PATH/download_bad_hosts.tmp4" > "$TMP_PATH/download_bad_hosts.out"
   cp "$TMP_PATH/download_bad_hosts.out" "$TMP_PATH/download_bad_hosts.tmp4"
   rm "$TMP_PATH/download_bad_hosts.out"
  fi
 done
 cp "$TMP_PATH/download_bad_hosts.tmp4" "$TMP_PATH/download_bad_hosts.out"
 rm "$TMP_PATH/download_bad_hosts.tmp2"
 rm "$TMP_PATH/download_bad_hosts.tmp3"
 rm "$TMP_PATH/download_bad_hosts.tmp4"

 exit 0

else

 # clean up from last run
 if [ -e "$TMP_PATH/download_bad_hosts.tmp1" ]; then
  rm "$TMP_PATH/download_bad_hosts.tmp1"
 fi

 # make sure output file doesnt exist
 if [ -e "$TMP_PATH/download_bad_hosts.out" ]; then
  rm "$TMP_PATH/download_bad_hosts.out"
 fi

 exit 1

fi
