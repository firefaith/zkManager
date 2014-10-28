#!/bin/bash

log="./zookeeper.out"
if [ -f "$log" ]; then
    # unit(MB)
    size=`du -sm "$log" | grep "$log" | awk '{print $1}'`
    limit=300
    # split log
    if [ $size -gt $limit ]; then
        cp $log "zookeeper-`date +%Y%m%d%H%M%S`.log"
        cat /dev/null > $log
    fi
fi

# clear hanging zkMonitor
#killpids=`ps -ef | grep zookeeper | grep srvr | awk '{printf("kill -9 %d;", $2);}' `
#if [ ! -n "$killpids" ]; then
#    echo $killpids
#    $killpids
#fi
ps -ef | grep zookeeper | egrep "srvr|zkMonitor" | grep -v " $$ " | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1

# check zkserver status
result=`./zkServer.sh status`
status=`echo $result | grep "Mode" | awk -F: '{print $2}'`

if [ "$status" != "" ]; then
    echo "zkserver is running, the role:$status"
    # zkserver is running
    exit 0
fi

# zkserver may not work
line=`echo $result | grep "It is probably not running"`
if [ "$line" != "" ]; then
    # check if zkserver process is existed
    count=`ps -ef | grep zookeeper | grep zoo.cfg | wc -l`  
    if [ $count -eq 0 ]; then
        # zk is not running
        echo "start zkserver"
        ./zkServer.sh start
    else
        echo "zkserver is already running...but not work well, try to restart it"
        ./zkServer.sh restart
        exit 1
    fi
    
fi


