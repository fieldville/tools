#!/bin/sh

while true
do
    result=`ps -eo pid,user,stat,pcpu,command | awk '$3 !~ /S/ && $4 > 80 {print $0}'`
    if [ ! -z "$result" ]; then
        echo "##########" `date '+%Y/%m/%d %H:%M:%S'` "##########"
        echo $result
    fi
    sleep 1
done

