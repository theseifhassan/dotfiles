#!/bin/sh
mem=$(free -h | awk '/^Mem/ { print $3"/"$2 }' | sed 's/Gi/G/g; s/Mi/M/g')
printf "MEM: %s\n" "$mem"
