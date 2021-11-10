#!/bin/bash
# set -x
#display all submitted jobs by user name in a quick way
#./job_by_user.sh p1
#p1 name of user optional
#example
#./job_by_user.sh 
#return all submitted jobs of current user
#./job_by_user.sh wangdz
#return all submitted jobs of specified user wangdz

#edition log
#GMT+8
#2021/11/05 16:43:00 create initial version

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gpu_info="$(bash ${__dir}/tqueue.sh)"
ur=$USER
if [ $# -eq 0 ]
then
  echo "all jobs of user ${ur}:"
  echo "$gpu_info" | grep $ur
  exit 0
fi

if [ $# -gt 0 ]
then
  ur=$1
  echo "all jobs of user ${ur}:"
  echo "$gpu_info" | grep $ur
  exit 0
fi