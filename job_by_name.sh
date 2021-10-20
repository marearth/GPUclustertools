#!/bin/bash
#set -x
#check gpu consumption by name of job for runnning job
#job_by_name.sh p1 p2
#p1 name of job must
#p2 name of user optional default:current user
#example
#job_by_name.sh test_job
#return gpu consumption result of specified job
#example

#edited
#2021/04/25 11:36:00
#2021/05/02 12:56:30
#2021/05/09 08:39:00
#2021/10/20 17:23:00 optimize location of query GPU

ur=$USER
if [ $# -eq 0 ]
then
  echo "ERROR:not enough arguments!"
  exit 1
fi

if [ $# -gt 1 ]
then
  ur=$2
fi

jr=`(chk_gpu | grep $ur | grep $1)`
if ! [ -z "$jr" ]
then 
  echo "Node INFO. of submitted job:"
  echo $jr  | awk '{print}' 
  field9="`echo $jr | awk '{ print $9 }'`" 
  if [ -z "$field9" ]
  then
    echo "the job is not OK,Please wait for some Time"
    exit 1
  fi
  node=`echo $field9 | cut -d- -f1` 
  gpus=`echo $field9 | cut -d- -f2`
  IFS="/" read -ra arr <<< "$gpus"
  
  jr1=`(chk_gpuused $node | awk '/Default/ {print $0}')`
  jr2=`(echo "$jr1" | awk '/Default/ {print NR-1,$0}')`
  total=${#arr[*]}
  echo "Gpu consumption INFO. of submitted job:"
  for (( i=0; i<=$(( $total -1 )); i++ ))
  do 
  if [ $i -eq 0 ]
  then 
    continue
  fi
  echo "$jr2" | awk -v var="${arr[$i]}" '$1 == var {print $0}'
  done
else
  echo "this is no job for query"
fi
