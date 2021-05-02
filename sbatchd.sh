#!/bin/bash
#set -x
#submit slm file in a elegant delay
#sbatchd p1 
#p1 name_of_job.slm 

#example
#avoid waiting by running in the backhround
#sbatchd test_job.slm &
#generate submission infromation in the sbatch_test_job_info.txt file
#example

#edited
#2021/4/25  11:57:30

next_sign=0
curr_sign=0
job_num=0
if [ $# -eq 0 ]
then
    echo "error:not enough arguments"
    exit 2
fi
while true
do
    curr_sign=0
    job_num=$(squeue | grep "compute" | wc -l)
    if [ $job_num -lt 4 ]
    then
        curr_sign=1
    fi
    sleep 15m
    job_num=$(squeue | grep "compute" | wc -l)
    next_sign=0
    if [ $job_num -lt 4 ]
    then
        next_sign=1
    fi
    if [ $curr_sign -eq 1 -a $next_sign -eq 1 ]
    then
        if [ ${1: -4} != ".slm" ]
        then
            echo "error:invalid input format"
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
