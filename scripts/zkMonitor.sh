#! /bin/bash

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

