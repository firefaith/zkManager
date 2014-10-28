#! /bin/bash
usage="new a zookeeper cluster \n 
example:./new.sh zoo.cfg port1 port2 deploy.path package.path hostlist\n
note:\n
1)zoo.cfg must be a default template without server.x=hostip:port1:port2 information\n
2)port1=2888\n
3)port2=3888\n
4)deploy path:dir like /opt\n
5)package path:dir like /package/zookeeper,zookeeper is the package name\n
6)ip address must be stored in hostlist\n"
#check input vars
if [ $# -ne 6 ]
 then 
 echo -e "error:"$usage
 exit 1
fi
cp $1 "zoo.cfg" 
port1=$2
port2=$3
deploy_path=$4
pck_path=$5
hostlist=$6
#generate zoo.cfg
let i=1
while read ip
do
echo "server.$i=$ip:$port1:$port2" >>zoo.cfg
let "i+=1"
done < $hostlist
#read datadir
tmp=`grep "dataDir=" zoo.cfg`
data_dir=${tmp##*=}

if [ -z $data_dir ];
then 
echo "error:dataDir haven't configed in zoo.cfg."
exit 1
fi
#dispatch packages and myid on hosts
let i=1
for ip in `cat $hostlist`
do
echo "when copying files to $ip "
scp -r $pck_path root@$ip:$deploy_path/${pck_path##*/} > /dev/null
echo "copy zoo.cfg"
scp zoo.cfg root@$ip:$deploy_path/${pck_path##*/}/conf/ > /dev/null
echo "create data dir"
ssh $ip "[ ! -d $data_dir ]&& mkdir -p $data_dir" > /dev/null
echo "create myid"
ssh $ip "echo $i > $data_dir/myid" > /dev/null
echo "start zookeeper service in $ip"
ssh -n $ip "cd $deploy_path/${pck_path##*/}/bin;./zkServer.sh start"
let "i+=1"
done

#rm -f zoo.cfg
#start zookeeper when boot,and add check server to crontab
#please confirm zkMonitor.sh and do_cleanup.sh are located well

#for ip in `cat $hostlist`
#do
#  ssh $ip "echo $deploy_path/${pck_path##*/}'/bin/zkServer.sh start' >> /etc/rc.d/rc.local"> /dev/null
#  ssh $ip "echo '*/5 * * * * /bin/bash' $deploy_path/${pck_path##*/}'/bin/zkMonitor.sh' > /dev/null 2>&1 '>>/var/spool/cron/root" > /dev/null
#  ssh $ip "echo '*/5 * * * * /bin/bash' $deploy_path/${pck_path##*/}'/bin/do_cleanup.sh "$data_dir" > /tmp/zk_cleanup.log 2>&1'>>/var/spool/cron/root" > /dev/null
#  ssh $ip "echo /sbin/service crond start >> /etc/rc.d/rc.local"
#  ssh $ip "/sbin/service crond start" > /dev/null
#done
