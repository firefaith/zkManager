#! /bin/bash
usage="example: ./add.sh atype ip original_zoo.cfg target_install.path package.path original_host.list\n
zoo.cfg and host.list will be edited.
1)atype:s or m ,s for one ip,m for iplist file
2)ip:ip or iplistfile path,add to cluster
3)zoo.cfg:current configuration file
4)install.path:like /opt
5)package.path:like ../pacakge/zookeeper
6)host.list:ips' address stored. "
#check input vars
if [ $# -ne 6 ]
then
  echo -e "error:less inputs.\n$usage"
  exit 1
fi

atype=$1
ipvar=$2
zoo_file=$3
install_path=$4
pck_path=$5
host_list=$6

#get myid
lastline=`tail -1 $zoo_file`
myid=`echo $lastline|grep -Eo 'server\.[0-9]{1,}\='|grep -Eo '[0-9]{1,}'`
myport=`echo $lastline|grep -Eo ':[0-9]{4}:[0-9]{4}'` #:2888:3888

#get data dir
tmp=`grep "dataDir=" $zoo_file`
data_dir=${tmp##*=}


case $atype in
s)
grep "=${ipvar}" $zoo_file &&
{
  echo "error:ip $ipvar have existed before"
  exit 1
} || {
#myid +1
let "myid+=1"
#add server to zoo.cfg
echo "server.${myid}=${ipvar}${myport}" >>$zoo_file
#copy package files and zoo.cfg to remote host
scp -r $pck_path root@$ipvar:$install_path/${pck_path##*/} > /dev/null
scp $zoo_file root@$ipvar:$install_path/${pck_path##*/}/conf/ > /dev/null
#write myid to remote host in the data dir
ssh $ipvar "echo $myid >$data_dir/myid"

#add regular task to conrb

#start remote host zookeeper
ssh $ipvar "cd $install_path/${pck_path##*/}/bin;./zkServer.sh start"
}
;;
m)
for ip in `cat $ipvar`
  do
    grep "=${ip}" $zoo_file &&
    { 
       echo "error:ip $ipvar have existed before,so it doesn't add to list"
     } || {
    let "myid+=1"
    echo "server.$myid=$ip$myport">>$zoo_file
	ips[$i]=$ip
	myids[$i]=$myid
	let "i+=1"
	}
  done
let i=0
for ip in ${ips[@]}
  do
    echo "copy package files to $ip"
    scp -r $pck_path root@$ip:$install_path/${pck_path##*/} > /dev/null
    scp $zoo_file root@$ip:$install_path/${pck_path##*/}/conf/ >/dev/null
    ssh -n $ip "echo ${myids[$i]} > $data_dir/myid"
	echo "n=$i ,myid=${myids[$i]}"
	let "i+=1"
    ssh -n $ip "cd $install_path/${pck_path##*/}/bin;./zkServer.sh start"
  done
  ;;
?)
  echo "error:wrong atype,please confirm s/m?"
  exit 1;;
esac

#copy zoo.cfg to other hosts in host.list,restart zkserver
while read line
do
  scp $zoo_file root@$line:$install_path/${pck_path##*/}/conf/ > /dev/null
  ssh $line "cd $install_path/${pck_path##*/}/bin;./zkServer.sh restart"
done < $host_list

case $atype in
s)
  #add ip to host.list
  echo $ipvar >> $host_list
  exit 0;;
m)
 for ip in ${ips[@]}
   do
   echo $ip >> $host_list
   done
;;
?)exit 1;;
esac

echo "finished."
