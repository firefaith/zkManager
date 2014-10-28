#! /bin/bash
usage="1:hostname/ip address"

function map2ip(){
host=$1
if [[ "$host"="[a-zA-Z].*" ]];then
tmp=`grep "$host" /etc/hosts`
ip=`echo $tmp|awk '{print $1;}'`
echo "$ip"
else
echo "$host"
fi
}

myip=`map2ip $1`
echo "myip=$myip"


