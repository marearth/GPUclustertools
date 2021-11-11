#!/bin/bash
# set -x
#get statistical information of state of jobs for specified type of GPU
#gpu_summmary.sh p1
#p1 encoded number of type of GPU  e.g.  3--->3090RTX 2--->2080Ti  1--->1080Ti

#example 
#gpu_summary.sh 3
#check state of jobs for 3090RTX GPU
#example

#edited 
#GMT+8 
#2021/4/25 11:49:30 update usage comments
#2021/4/27 10:51:30 fixed resources conflict
#2021/4/27 20:32:30 optimized performance by reducing disk I/O
#2021/5/02 20:45:30 add 8:E type gpu
#2021/10/26 12:23:00 optimize output of gpu queue and used gpu information
#2021/11/05 14:30:00 optimize cache file and display of type of job
#2021/11/11 15:52:00 add support for RTX 3080 Ti GPU

start=`date +%s`

# gf=`chk_gpu`
# gf1=$gf
# gf2=$gf
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


echo "-------------------Number of GPU jobs--------------------"


(
bash ${__dir}/gpu_used.sh
) > ${__dir}/gs_gused_info.temp &

(
bash ${__dir}/tqueue.sh  | grep "1:gpus" | awk '$7 == "Q" {print $4}'
) > ${__dir}/gs_queue_info.temp &


wait



ginfo=$(<${__dir}/gs_gused_info.temp)
ginfo2=$ginfo
ginfo4=$ginfo
ginfo8=$ginfo


qinfo=$(<${__dir}/gs_queue_info.temp)
qinfo2=$qinfo
qinfo4=$qinfo
qinfo8=$qinfo

case $1 in 
    3)
        ( 
        num_single="$(echo  "$ginfo"  | grep  "[1-9][0-9][0-9](A)" | grep -o '[ ]' | wc -l)"
        nfg="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](A)" | grep -o '[ ]\|[x]' | wc -l)"
        w_jobs="$(echo "$qinfo" | grep -o '1:A' | wc -l)"

        num_single_g="$(echo  "$ginfo"  | grep  "[1-9][0-9][0-9](G)" | grep -o '[ ]' | wc -l)"
        nfg_g="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](G)" | grep -o '[ ]\|[x]' | wc -l)"
        w_jobs_g="$(echo "$qinfo" | grep -o '1:G' | wc -l)"

        echo $num_single $nfg $w_jobs $num_single_g $nfg_g $w_jobs_g
        ) > ${__dir}/gs1.temp &


        (
        num_double="$(echo  "$ginfo2"  | grep  "[1-9][0-9][0-9](B)" | grep -o '[ ]' | wc -l)"
        nfn_2="$(echo  "$ginfo2"  | grep  "[1-9][0-9][0-9](B)" | wc -l)"
        nfj_2="$(echo "${nfn_2}*4" |  bc )"
        num_d_jobs="$(echo "${num_double}/2" | bc )" 
        w_jobs="$(echo "$qinfo2" | grep -o '2:B' | wc -l)"
        echo $num_d_jobs $nfj_2 $w_jobs
        ) > ${__dir}/gs2.temp &


        (
        num_quadruple="$(echo  "$ginfo4"  | grep  "[1-9][0-9][0-9](C)" | grep -o '[ ]' | wc -l)"
        nfn_4="$(echo  "$ginfo4"  | grep  "[1-9][0-9][0-9](C)" | wc -l)"
        nfj_4="$(echo "${nfn_4}*2" |  bc )"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )" 
        w_jobs="$(echo "$qinfo4" | grep -o '4:C' | wc -l)"
        echo $num_q_jobs $nfj_4 $w_jobs
        ) > ${__dir}/gs3.temp &


        (
        num_eight="$(echo  "$ginfo8"  | grep  "[1-9][0-9][0-9](F)" | grep -o '[ ]' | wc -l)"
        nfn_8="$(echo  "$ginfo8"  | grep  "[1-9][0-9][0-9](F)" | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )" 
        w_jobs="$(echo "$qinfo8" | grep -o '8:F' | wc -l)"
        echo $num_e_jobs $nfn_8 $w_jobs
        ) > ${__dir}/gs4.temp &

        wait



        IFS=" " read -ra r1 <<< "$(cat ${__dir}/gs1.temp)" 
        IFS=" " read -ra r2 <<< "$(cat ${__dir}/gs2.temp)" 
        IFS=" " read -ra r3 <<< "$(cat ${__dir}/gs3.temp)" 
        IFS=" " read -ra r4 <<< "$(cat ${__dir}/gs4.temp)" 
        echo "---Type of Job for RTX 3090/RTX 3080 Ti---        spare/total/waiting"
        echo "number of jobs for single gpu(1A):                    ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for single gpu(3080Ti:1G):             ${r1[3]}/${r1[4]}/${r1[5]}"
        echo "number of jobs for double gpus(2B):                   ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus(4C):                ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus(8F):                    ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    2)       
        (
        num_single="$(echo  "$ginfo" |  grep '[1-9][0-9][0-9](s)' | grep -o '[ ]' | wc -l)"
        nfn="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](s)" | wc -l)"
        nfj="$(echo "${nfn}*8" |  bc )"
        w_jobs="$(echo "$qinfo" | grep -o '1:s' | wc -l)"
        echo $num_single $nfj $w_jobs
        ) > ${__dir}/gs1.temp &

        (
        num_double="$(echo  "$ginfo2" |  grep '[1-9][0-9][0-9](d)' | grep -o '[ ]' | wc -l)"
        num_d_jobs="$(echo "${num_double}/2" | bc )"
        nfn="$(echo  "$ginfo2" |  grep  "[1-9][0-9][0-9](s)" | wc -l)"
        nfj="$(echo "${nfn}*4" |  bc )"
        w_jobs="$(echo "$qinfo2" | grep -o '2:d' | wc -l)"
        echo $num_d_jobs $nfj $w_jobs
        ) > ${__dir}/gs2.temp & 

        (
        num_quadruple="$(echo  "$ginfo4" |  grep '[1-9][0-9][0-9](q)' | grep -o '[ ]' | wc -l)"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )"
        nfn="$(echo  "$ginfo4" |  grep  "[1-9][0-9][0-9](q)" | wc -l)"
        w_jobs="$(echo "$qinfo4" | grep -o '4:q' | wc -l)"
        nfj="$(echo "${nfn}*2" |  bc )"
        echo $num_q_jobs $nfj $w_jobs
        ) > ${__dir}/gs3.temp &

        (
        num_eight="$(echo  "$ginfo8" |  grep '[1-9][0-9][0-9](e)' | grep -o '[ ]' | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )"
        nfn="$(echo  "$ginfo8" |  grep  "[1-9][0-9][0-9](e)" | wc -l)"
        w_jobs="$(echo "$qinfo8" | grep -o '8:e' | wc -l)"
        echo $num_e_jobs $nfn $w_jobs
        ) > ${__dir}/gs4.temp &

        wait

        IFS=" " read -ra r1 <<< "$(cat ${__dir}/gs1.temp)" 
        IFS=" " read -ra r2 <<< "$(cat ${__dir}/gs2.temp)" 
        IFS=" " read -ra r3 <<< "$(cat ${__dir}/gs3.temp)" 
        IFS=" " read -ra r4 <<< "$(cat ${__dir}/gs4.temp)" 

        echo "---Type of Job for 2080Ti---         spare/total/waiting"
        echo "number of jobs for single gpu(1s):       ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for double gpus(2d):      ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus(4q):   ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus(8e):       ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    1)
        (
        num_single="$(echo  "$ginfo" |  grep '[1-9][0-9][0-9](S)' | grep -o '[ ]' | wc -l)"
        nfg="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](S)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}" |  bc )"
        w_jobs="$(echo "$qinfo" | grep -o '1:S' | wc -l)"
        echo $num_single $nfj $w_jobs
        ) > ${__dir}/gs1.temp &

        (
        num_double="$(echo  "$ginfo2" |  grep '[1-9][0-9][0-9](D)' | grep -o '[ ]' | wc -l)"
        num_d_jobs="$(echo "${num_double}/2" | bc )"
        nfg="$(echo  "$ginfo2" |  grep  "[1-9][0-9][0-9](D)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/2" |  bc )"
        w_jobs="$(echo "$qinfo2" | grep -o '2:D' | wc -l)"
        echo $num_d_jobs $nfj $w_jobs
        ) > ${__dir}/gs2.temp &

        (
        num_quadruple="$(echo  "$ginfo4" |  grep '[1-9][0-9][0-9](Q)' | grep -o '[ ]' | wc -l)"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )"
        nfg="$(echo  "$ginfo4" |  grep  "[1-9][0-9][0-9](Q)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/4" |  bc )"
        w_jobs="$(echo "$qinfo4" | grep -o '4:Q' | wc -l)"
        echo $num_q_jobs $nfj $w_jobs
        ) > ${__dir}/gs3.temp &

        (
        num_eight="$(echo  "$ginfo8" |  grep '[1-9][0-9][0-9](E)' | grep -o '[ ]' | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )"
        nfg="$(echo  "$ginfo8" |  grep  "[1-9][0-9][0-9](E)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/8" |  bc )"
        w_jobs="$(echo "$qinfo8" | grep -o '8:E' | wc -l)"
        echo $num_e_jobs $nfj $w_jobs
        ) > ${__dir}/gs4.temp &

        wait

        IFS=" " read -ra r1 <<< "$(cat ${__dir}/gs1.temp)" 
        IFS=" " read -ra r2 <<< "$(cat ${__dir}/gs2.temp)" 
        IFS=" " read -ra r3 <<< "$(cat ${__dir}/gs3.temp)"
        IFS=" " read -ra r4 <<< "$(cat ${__dir}/gs4.temp)"  

        echo "---Type of Job for 1080Ti---         spare/total/waiting"
        echo "number of jobs for single gpu(1S):       ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for double gpus(2D):      ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus(4Q):   ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus(8E):       ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    *)
        echo "Not valid argument!"
        exit 1
        ;;
esac

rm ${__dir}/gs*.temp
end=`date +%s`
runtime=$((end-start))
echo "runtime:" $runtime"s"
