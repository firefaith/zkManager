#! /bin/bash
usage="delete zookeeper node to the host by ip
example:\n
./del.sh ip zoo.cfg install.path package.path host.list\n
1)ip:ip or iplistfile path,add to cluster\n
2)zoo.cfg:current configuration file\n
3)install.path:like /opt\n
4)package.path:like ../pacakge/zookeeper\n
5)host.list:ips' address stored.\n

\n"
#check input vars
if [ $# -ne 5 ]
 then 
 echo -e "error:"$usage
 exit 1
fi

ip=$1
zoo_file=$2
install_path=$3
pck_path=$4
host_list=$5

#zoo.cfg ,
#find ip line ,map to server.x
#if server.x == last server.n ,del ip(server.n)
#or write  server.x = ip(server.n):2888:3888,
#del lastline(server.n)
#myid=x, send to ip(server.n)
tmp=`grep -Eo "[0-9]{1,}=$ip" $zoo_file`
find_id=${tmp%%=*}
#echo $find_id
if [ $find_id ]
then
  lastline=`tail -1 $zoo_file`
  tmp=`echo $lastline|grep -Eo "[0-9]{1,}=[0-9.]{1,}"`
  last_id=${tmp%%=*}
  last_ip=${tmp##*=}
  
  ##get data dir
  tmp=`grep "dataDir=" $zoo_file`
  data_dir=${tmp##*=}

  #echo $last_id $last_ip 
  ##if ip located in the last line of zoo.cfg,delete it directly. 
    if [ $find_id -ne $last_id ]
      then  
      ##echo "find_id!=last_id,$find_id,$last_id"
      sed -i "s/$ip/$last_ip/" $zoo_file #replace ip with last ip
      ##get data dir
      tmp=`grep "dataDir=" $zoo_file`
      data_dir=${tmp##*=}
      ##rewrite the last host myid file
      ssh $last_ip "echo $find_id>$data_dir/myid" 
      #echo $find_ip>$cluster_dir/myid
    fi
  ##del last line in zoo.cfg
  sed -i "\$d" $zoo_file
  ##del ip in host.list
  sed -i "/$ip/d" $host_list
  #stop the serive
  ssh -n $ip "cd $install_path/${pck_path##*/}/bin;./zkServer.sh stop"
  ##delete remote host(ip) zookeeper files and data file
  ssh -n $ip "rm -rf $data_dir $install_path/${pck_path##*/}"
  ##copy zoo.cfg to all host in host.list and restart zookeeper
  while read line
  do
    scp $zoo_file root@$line:$install_path/${pck_path##*/}/conf
    ssh $line "cd $install_path/${pck_path##*/}/bin;./zkServer.sh restart"
  done < $host_list
  echo "completed!"
  exit 0
else
  echo "error:$ip is not existed."
  exit 1
fi
