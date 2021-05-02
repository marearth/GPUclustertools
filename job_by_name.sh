#!/bin/bash
#set -x
#check gpu consumption by name of job for runnning job
#job_by_name.sh p1
#p1 name of job

#example
#job_by_name.sh test_job
#return gpu consumption result of specified job
#example

#edited
#2021/04/25 11:36:00
#2021/05/02 12:56:30

(chk_gpu | grep $USER | grep $1) > jbn_result.txt
if [ -s jbn_result.txt ]
then 
  echo "Node INFO. of submitted job:"
  cat jbn_result.txt  | awk '{print}' 
  field9="`cat jbn_result.txt | awk '{ print $9 }'`" 
  if [ -z "$field9" ]
  then
    echo "the job is not OK,Please wait for some Time"
    rm jbn_result.txt
    exit 1
  fi
  node=`echo $field9 | cut -d- -f1` 
  gpus=`echo $field9 | cut -d- -f2`
  IFS="/" read -ra arr <<< "$gpus"
  
  (chk_gpuused $node | awk '/Default/ {print (NR-11)/4,$0}') > jbn_result.txt
  total=${#arr[*]}
  echo "Gpu consumption INFO. of submitted job:"
  for (( i=0; i<=$(( $total -1 )); i++ ))
  do 
  if [ $i -eq 0 ]
  then 
    continue
  fi
  awk -v var="${arr[$i]}" '$1 == var {print $0}' jbn_result.txt 
  done
else
  echo "this is no job for query"
fi
rm jbn_result.txt
