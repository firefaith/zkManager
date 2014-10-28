#! /bin/bash
usage="drop a zookeeper cluster \n 
example:./drop.sh zoo.cfg zkhome hostlist\n
note:\n
1)zoo.cfg\n
2)zkhome:dir like /opt/zookeeper\n
3)ip address must be stored in hostlist\n"
#check input vars
if [ $# -ne 3 ]
 then 
 echo -e "error:"$usage
 exit 1
fi

zoocfg=$1 
zkhome=$2
hostlist=$3
#read datadir
tmp=`grep "dataDir=" $zoocfg`
data_dir=${tmp##*=}


for ip in `cat $hostlist`
do
echo -e "\nprocessing $ip stop zookeeper"
ssh -n $ip "cd $zkhome/bin;./zkServer.sh stop"
#sed -i "/$ip/d" $hostlist
done

for ip in `cat $hostlist`
do
echo "delete $ip zookeeper"
ssh -n $ip "rm -rf  $data_dir $zkhome" > /dev/null
done

#rm -f zoo.cfg


