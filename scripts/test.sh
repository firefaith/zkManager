#! /bin/bash
#check input vars
usage="test.sh a|d|h|dl|sz|sh|t;\n a:add ,d:delete,h:help,dl:delete last line in zoo.cfg\n
sz:show zoo.cfg;sh:show host.list;t:test"
if [ $# -ne 1 ]
then 
  echo -e "error:$usage"
  exit 1;
fi

CMD_PATH=/opt/ZKManagerV2/scripts
PCK_PATH=/opt/ZKManagerV2/package/zookeeper
CONF_PATH="/opt/ZKManagerV2/test/zoo.cfg"
INSTALL_PATH=/opt
HOST_LIST="/opt/ZKManagerV2/test/host.list"


IP="10.4.12.96"
case $1 in
a|add)sh $CMD_PATH/add.sh $IP $CONF_PATH $INSTALL_PATH $PCK_PATH $HOST_LIST
;;
d|del)sh $CMD_PATH/del.sh $IP $CONF_PATH $INSTALL_PATH $PCK_PATH $HOST_LIST
;;
h)echo $usage;;
dl)sed -i "\$d" $CONF_PATH;;
sz)more $CONF_PATH;;
sh)more $HOST_LIST;;
t)
#add a service to crontab

#start service

#set start when host start
;;
esac
