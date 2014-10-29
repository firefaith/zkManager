#! /bin/bash
usage="cron.sh:add or del a task in the crontab,and start with boot\n
1)ctype:s/m ,single ip or mutiple ips\n
2)ip/iplist ,one detail ip or iplist file\n
3)zkhome,zookeeper install home\n
4)scriptname ,the script name(shell file name) should be add to crontab\n
5)action:a/d,add or delete\n"
if [ $# -ne 5 ]
 then
 echo -e "error:\n"$usage
 exit 1
fi

ctype=$1
ipvar=$2
zkhome=$3
script_name=$4
action=$5

case $script_name in
"zkMonitor.sh")
taskline="*/5 * * * * cd $zkhome/bin && ./zkMonitor.sh > /dev/null 2>&1";
;;
"do_cleanup.sh")
taskline="07 01 * * * cd $zkhome/bin && ./do_cleanup.sh > /tmp/zk_cleanup.log 2>&1"
;;
?)
echo "error:do not support $script_name currently,please add to the script."
exit 1;;
esac

echo "$taskline"

function addone(){

	ip=$1
	home=$2
	script=$3

	#check script file is existed or not
	ssh -n $ip "[ -e $home/bin/$script ]"

	if [ $? -ne 0 ]
	then
		echo "error:$script does not exist in $ip."
		exit 1;
	fi

  #check crontab whether set or not
  ssh -n $ip "grep $script /var/spool/cron/root" > /dev/null
  if [ $? -eq 0 ]
  then
    echo "$ip crontab has setted before"
    exit 1;
  fi
  ssh -n $ip "echo '$taskline' >>/var/spool/cron/root" > /dev/null 
  ssh -n $ip "service crond restart" >/dev/null
  echo "$ip : add $script  to crontab complete"
  
  #add start cron start with boot
  ssh -n $ip "grep 'crond start' /etc/rc.d/rc.local" > /dev/null
  if [ $? -eq 1 ];then
    ssh -n $ip "echo '/sbin/service crond start'>>/etc/rc.d/rc.local" > /dev/null
	echo "$ip add cron start to boot successfully."
  else
    echo "$ip has set cron start in boot already."
  fi
}

delone(){
	ip=$1
	home=$2
	script=$3

  #check crontab whether set or not
  ssh -n $ip "grep $script /var/spool/cron/root" > /dev/null
  if [ $? -eq 1 ]
  then
    echo "$ip crontab has not setted before,delete is cancelled."
    exit 1;
  fi
  ssh -n $ip "sed -i /$script/d /var/spool/cron/root" > /dev/null
  ssh -n $ip "service crond restart" >/dev/null
  echo "$ip : del  $script  from crontab complete"
}

#main task
case $ctype in
s)
  case $action in
  a|add)
  addone $ipvar $zkhome $script_name
  ;;
  d|del|delete)
  delone $ipvar $zkhome $script_name
  ;;
  ?)
  echo "error action=$action. please input :a/add ,d/del/delete."
  exit 1;
  ;;
  esac
;;
m)
 for ip in `cat $ipvar`
 do
 case $action in
  a|add)
  addone $ip $zkhome $script_name
  ;;
  d|del|delete)
  delone $ip $zkhome $script_name
  ;;
  ?)
  echo "error action=$action. please input a;add ,d;del;delete."
  exit 1;
  ;;
  esac
 done
;;
?)echo "error:wrong ctype,make sure you input char is s or m."
  exit 1;
  ;;
esac
