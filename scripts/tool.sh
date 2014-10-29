#! /bin/bash
usage="map2ip\n 1:hostname"
if [ $# -ne 1 ];then
 echo -e $usage
 exit 1;
fi

function t1(){
echo $1
}
function t2(){
t1 $2
echo $1
}

t2 "t2-1" "t2-2"

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


