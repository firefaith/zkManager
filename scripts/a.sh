#! /bin/bash
grep -q $1 $2 &&
{
echo "find"
} ||
{
  echo "not find"
for ip in `cat $2`
do
 ips[$i]=$ip
 let "i+=1"
done
}
let i=0
for ip in ${ips[@]}
do

echo "ip=${ips[$i]}"
let "i+=1"
done


