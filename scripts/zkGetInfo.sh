#! /bin/bash
usage="get zk infomation. ./zkGetInfo.sh ip port\n
make sure you have install nc locally."

if [ $# -ne 2 ]
  then
  echo -e $usage
  exit 1
fi

ip=$1
port=$2
echo stat|nc $ip $port > temp #base info
echo wchs|nc $ip $port >> temp #watch info
cli_flag=0
cli_n=0

while read line
do
  if [ $cli_flag -eq 1 ]
    then
    clients[$cli_n]=$line
    let "cli_n+=1"
  fi
  
  case $line in
  "Clients"*)let "cli_flag=1"
  ;;
  "")
  let "cli_flag=0"
  ;;
  "Zxid"*) zxid=${line##*Zxid:}
  ;;
  "Mode"*) role=${line##*Mode:}
  ;;
  "Node count"*) n_node=${line##*count:}
  ;;
  "Total watches"*) n_watch=${line##*watches:}
  ;;
  esac
done < temp

echo zxid:$zxid 
echo role:$role
echo n_node:$n_node
echo -e "clients:\n ${clients[*]}"
echo watchs:$n_watch
