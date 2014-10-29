#! /bin/bash
usage="./cmd.sh s|m ip|host.list zkhome command[start|stop|restart|status]\n
begin|end|reset|state\n
1) s|m : single ip or multiple ips in host.list\n
2)ip|host.list:ip address or ips in host.list file\n
3)zkhome:zookeeper install direciton,i.e. /opt/zookeeper\n
4)commmand:choose one of command {start,stop,restart,status}"

#check input vars

if [ $# -ne 4 ]
then 
echo -e "error:"$usage
exit 1
fi

iptype=$1
ipvar=$2
zkhome=$3
cmd=$4

cmd_sh="cd $zkhome/bin/;./zkServer.sh"

case $cmd in
start|begin)cmd=start;;
stop|end)cmd=stop;;
restart|reset)cmd=restart;;
status|state)cmd=status;;
jps)cmd=jps;;
esac


case $iptype in
s)
if [ $cmd = "jps" ]
then
jhome=`ssh -n $ipvar "source /etc/profile && echo \$JAVA_HOME"`
ssh -n $ipvar "$jhome/bin/$cmd"
exit 0
fi
ssh -n $ipvar "$cmd_sh $cmd"
exit 0;;
m)
if [ $cmd = "jps" ]
then
  for ip in `cat $ipvar`
  do
  echo -e "\nINFO of $ip"
  jhome=`ssh -n $ip "source /etc/profile && echo \$JAVA_HOME"`
  ssh -n $ip "$jhome/bin/$cmd"
  done
else
  for ip in `cat $ipvar`
    do
    echo -e "\nINFO of $ip "
    ssh -n $ip "$cmd_sh $cmd" 
    done < $ipvar
fi

    exit 0;;
?)
echo "error:ipvar is wrong,must be s or m."
exit 1;;

esac
