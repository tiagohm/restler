#!/bin/sh

killables=$(ps aux | grep gradle-launcher.*.jar | grep -v mykill | grep -v grep)
if [ ! "${killables}" = "" ]
then
  echo "You are going to kill some process:"
  echo "${killables}"
else
  echo "No process with the pattern $1 found."
  return
fi
for pid in $(echo "${killables}" | awk '{print $2}')
do
echo killing $pid "..."
kill $pid 
echo $pid killed
done
