#!/bin/bash
#---------------------------------------------------------------------------------#
# Name       = Cron Checker                                                       #
# Date       = 12/01/2018                                                         #
# Author     = cmd-n-ctrl                                                         #
# Usage      = chmod 755 CronChecker.sh | ./CronChecker.sh                        #
#---------------------------------------------------------------------------------#

IFS=$'\n'

# Check list of running processes
running_processes=$(ps -eo command)

# Look for newly created processes
while true; do
  new_processes=$(ps -eo command)
  diff <(echo "$running_processes") <(echo "$new_processes") | grep [\<\>]
  sleep 1
  running_processes=$new_processes
done
