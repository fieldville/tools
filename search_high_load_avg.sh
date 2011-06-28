#!/bin/sh

while true
do
    result=`ps -eo pid,user,stat,command | awk '$3 !~ /S/ {print $0}' | grep -v 'ps -eo'`
    if [ ! -z "$result" ]; then
        echo "##########" `date '+%Y/%m/%d %H:%M:%S'` "##########"
        echo $result
    fi
    sleep 1
done

