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
#2021/10/22 15:08:00 add display of order of query job in the queue

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
    field4="`echo $jr | awk '{ print $4 }'`"
    field_id="`echo $jr | awk '{ print $1 }'`"
    gpu_type=`echo $field4 | cut -d= -f2`
    queue_info=`(echo "$gpu_info"  | grep "1:gpus" | grep "$gpu_type" | awk '$7 == "Q" {print $0}')`
    queue_line=`(echo "$queue_info" | awk '{print NR,$0}')`
    total_queue_jobs="$(echo "$queue_line" | wc -l)"
    job_location=`(echo "$queue_line" | awk -v var="$field_id" '$2 == var {print $1}')`
    echo "The job is queuing. Job order in the queue is ${job_location} / ${total_queue_jobs}. Please wait for a while."
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
