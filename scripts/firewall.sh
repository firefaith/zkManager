#! /bin/bash
#turn on / off the firewall with ip
#check input vars
usage="firewall.sh -s ip [-m ip.listfile] -c [on|off|add:port|del:port]
-s:single ip address\n
-m:multiple ips in one file\n
-c:commmand-turn on/off/ add one port/ deleteone port."
SUCCESS=0
FAILURE=1
isdigit ()    # Tests whether *entire string* is numerical.
{             # In other words, tests for integer variable.
  [ $# -eq 1 ] || return $FAILURE

  case $1 in
    *[!0-9]*|"") return $FAILURE;;
              *) return $SUCCESS;;
  esac
}

if [ $# -eq 0 ]
then
  echo -e $usage
  exit 1
fi

while getopts "s:m:c:" opt
do
  case $opt in
  s)ip=$OPTARG;;
  m)ips_file=$OPTARG;;
  c)cmd=$OPTARG;;
  ?)echo "error:input var is invalid."
    echo -e $usage
    exit 1;;
  esac
done
echo command1:$cmd
 case $cmd in
    on)cmd="service iptables start";;
    off)cmd="service iptables stop";;
    add:*)
          port=${cmd##*:}
          cmd="add";;
    del:*)
          port=${cmd##*:}
          cmd="del";;
    ?)echo"error:input var is invalid."
      echo "on/off/add:port[2181]/del:port"
      exit 1;;
 esac
#port var 
if isdigit $port;then
  if [ $ip ];then
  echo "ip"
  exit 0
  fi
  if [ $ips_file ];then
  echo "ips.list"
  while read line
  do
    echo $line
  done
  exit 0
  fi
else
echo "is not digit"
exit 1
fi

