#! /bin/bash
#input is the datadir of zookeeper
datadir=$1
echo "'data + "%Y%m%d %H%M%S"'"
./zkCleanup.sh $datadir -n 64
