#! /bin/bash
usage="
1)ctype:s/m
2)ip/iplist
3)script
4)zkhome"

ctype=$1
ipvar=$2
scr=$3
zkhome=$4

case $ctype in
s)
  scp $scr root@$ipvar:$zkhome > /dev/null
  ssh -n $ipvar "grep $scr /etc/crontab" > /dev/null
  if [ $? -ne 0 ]
  then
    echo "crontab has setted before"
    exit 1;
  fi
  ssh -n $ipvar "echo 0-59/2 * * * * root $zkhome/$scr>>/etc/crontab" > /dev/null
  ssh -n $ipvar "service crond start" >/dev/null
;;
m)
 for ip in `cat $ipvar`
 do
   scp $scr root@$ip:$zkhome
   ssh -n $ip "grep $scr /etc/crontab" > /dev/null
   if [ $? -eq 0 ]
   then
   ssh -n $ip "echo 0-59/2 * * * * root $zkhome/$scr>>/etc/crontab">/dev/null
   ssh -n $ip "service crond start">/dev/null
   else
     echo "$ip has setted $scr in crontab before."
   fi
 done
;;
?)echo "error:wrong ctype,make sure you input char is s or m."

  exit 1;;
