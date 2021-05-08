#!/bin/bash
#set -x
#submit slm file in a elegant delay
#sbatchd p1 p2 p3
#p1 name_of_job.slm must
#p2 maximum number of available jobs  optional  default:4
#p3 interval time between scanning(minute) optional default:15

#example
#avoid waiting by running in the background
#sbatchd test_job.slm &
#generate submission infromation in the sbatch_test_job_info.txt file
#example

#edited
#2021/4/25  11:57:30
#2021/5/5   19:52:30
#2021/5/6   22:44:30

next_sign=0
curr_sign=0
job_num=0
capacity=4
sleep_time=15

if [ $# -eq 0 ]
then
    echo "ERROR:not enough arguments!"
    exit 2
fi

if [ $# -eq 2 ];then
    re='[0-9]'
    if ! [[ $2 =~ $re ]];then
        echo "ERROR:not valid argument!"
        exit 3
    fi
    capacity=$2
fi

if [ $# -gt 2 ];then
    re='[0-9][0-9]'
    if ! [[ $3 =~ $re ]];then
        echo "ERROR:not valid argument!"
        exit 4
    fi
    sleep_time=$3
fi

while true
do
    curr_sign=0
    job_num=$(squeue | grep "compute" | wc -l)
    if [ $job_num -lt $capacity ]
    then
        curr_sign=1
    fi
    sleep ${sleep_time}m
    job_num=$(squeue | grep "compute" | wc -l)
    next_sign=0
    if [ $job_num -lt $capacity ]
    then
        next_sign=1
    fi
    if [ $curr_sign -eq 1 -a $next_sign -eq 1 ]
    then
        if [ ${1: -4} != ".slm" ]
        then
            echo "ERROR:invalid input format!"
            exit 1
        fi
        now="$(date)"
        name=`echo $1 | cut -d. -f1`
        sbatch $1 > sbatch_${name}_info.txt
        echo "$1 has been submited at $now" >> sbatch_${name}_info.txt
        sleep 5
        squeue >> sbatch_${name}_info.txt
        exit 0
    fi
done
