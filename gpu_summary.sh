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
#2021/4/25 11:49:30 update usage comments
#2021/4/27 10:51:30 fixed resources conflict
#2021/4/27 20:32:30 optimized performance by reducing disk I/O
#2021/5/02 20:45:30 add 8:E type gpu

start=`date +%s`

gf=`chk_gpu`
gf1=$gf
gf2=$gf

echo "-------------------Number of GPU jobs--------------------"
(

echo "$gf1" | sed -n '/GPU used detail/,$p'
) > gs1_info.txt &

(
echo "$gf2"  | grep "1:gpus" | awk '$7 == "Q" {print $4}'
) > gs2_info.txt &

wait

echo "waiting info.:" >> gs1_info.txt 
cat gs2_info.txt >> gs1_info.txt

ginfo=$(<gs1_info.txt)
ginfo2=$(<gs1_info.txt)
ginfo4=$(<gs1_info.txt)
ginfo8=$(<gs1_info.txt)

case $1 in 
    3)
        ( 
        num_single="$(echo  "$ginfo"  | grep  "[1-9][0-9][0-9](A)" | grep -o '[ ]' | wc -l)"
        nfg="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](A)" | grep -o '[ ]\|[x]' | wc -l)"
        w_jobs="$(echo "$ginfo" | sed -n '/waiting info./,$p' | grep -o '1:A' | wc -l)"
        echo $num_single $nfg $w_jobs
        ) > gs1.txt &


        (
        num_double="$(echo  "$ginfo2"  | grep  "[1-9][0-9][0-9](B)" | grep -o '[ ]' | wc -l)"
        nfn_2="$(echo  "$ginfo2"  | grep  "[1-9][0-9][0-9](B)" | wc -l)"
        nfj_2="$(echo "${nfn_2}*4" |  bc )"
        num_d_jobs="$(echo "${num_double}/2" | bc )" 
        w_jobs="$(echo "$ginfo2" | sed -n '/waiting info./,$p' | grep -o '2:B' | wc -l)"
        echo $num_d_jobs $nfj_2 $w_jobs
        ) > gs2.txt &


        (
        num_quadruple="$(echo  "$ginfo4"  | grep  "[1-9][0-9][0-9](C)" | grep -o '[ ]' | wc -l)"
        nfn_4="$(echo  "$ginfo4"  | grep  "[1-9][0-9][0-9](C)" | wc -l)"
        nfj_4="$(echo "${nfn_4}*2" |  bc )"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )" 
        w_jobs="$(echo "$ginfo4" | sed -n '/waiting info./,$p' | grep -o '4:C' | wc -l)"
        echo $num_q_jobs $nfj_4 $w_jobs
        ) > gs3.txt &


        (
        num_eight="$(echo  "$ginfo8"  | grep  "[1-9][0-9][0-9](F)" | grep -o '[ ]' | wc -l)"
        nfn_8="$(echo  "$ginfo8"  | grep  "[1-9][0-9][0-9](F)" | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )" 
        w_jobs="$(echo "$ginfo8" | sed -n '/waiting info./,$p' | grep -o '8:F' | wc -l)"
        echo $num_e_jobs $nfn_8 $w_jobs
        ) > gs4.txt &

        wait



        IFS=" " read -ra r1 <<< "$(cat gs1.txt)" 
        IFS=" " read -ra r2 <<< "$(cat gs2.txt)" 
        IFS=" " read -ra r3 <<< "$(cat gs3.txt)" 
        IFS=" " read -ra r4 <<< "$(cat gs4.txt)" 
        echo "---Type of Job for RTX3090---        spare/total/waiting"
        echo "number of jobs for single gpu:       ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for double gpus:      ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus:   ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus:       ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    2)       
        (
        num_single="$(echo  "$ginfo" |  grep '[1-9][0-9][0-9](s)' | grep -o '[ ]' | wc -l)"
        nfn="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](s)" | wc -l)"
        nfj="$(echo "${nfn}*8" |  bc )"
        w_jobs="$(echo "$ginfo" | sed -n '/waiting info./,$p' | grep -o '1:s' | wc -l)"
        echo $num_single $nfj $w_jobs
        ) > gs1.txt &

        (
        num_double="$(echo  "$ginfo2" |  grep '[1-9][0-9][0-9](d)' | grep -o '[ ]' | wc -l)"
        num_d_jobs="$(echo "${num_double}/2" | bc )"
        nfn="$(echo  "$ginfo2" |  grep  "[1-9][0-9][0-9](s)" | wc -l)"
        nfj="$(echo "${nfn}*4" |  bc )"
        w_jobs="$(echo "$ginfo2" | sed -n '/waiting info./,$p' | grep -o '2:d' | wc -l)"
        echo $num_d_jobs $nfj $w_jobs
        ) > gs2.txt & 

        (
        num_quadruple="$(echo  "$ginfo4" |  grep '[1-9][0-9][0-9](q)' | grep -o '[ ]' | wc -l)"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )"
        nfn="$(echo  "$ginfo4" |  grep  "[1-9][0-9][0-9](q)" | wc -l)"
        w_jobs="$(echo "$ginfo4" | sed -n '/waiting info./,$p' | grep -o '4:q' | wc -l)"
        nfj="$(echo "${nfn}*2" |  bc )"
        echo $num_q_jobs $nfj $w_jobs
        ) > gs3.txt &

        (
        num_eight="$(echo  "$ginfo8" |  grep '[1-9][0-9][0-9](e)' | grep -o '[ ]' | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )"
        nfn="$(echo  "$ginfo8" |  grep  "[1-9][0-9][0-9](e)" | wc -l)"
        w_jobs="$(echo "$ginfo8" | sed -n '/waiting info./,$p' | grep -o '8:e' | wc -l)"
        echo $num_e_jobs $nfn $w_jobs
        ) > gs4.txt &

        wait

        IFS=" " read -ra r1 <<< "$(cat gs1.txt)" 
        IFS=" " read -ra r2 <<< "$(cat gs2.txt)" 
        IFS=" " read -ra r3 <<< "$(cat gs3.txt)" 
        IFS=" " read -ra r4 <<< "$(cat gs4.txt)" 

        echo "---Type of Job for 2080Ti---         spare/total/waiting"
        echo "number of jobs for single gpu:       ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for double gpus:      ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus:   ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus:       ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    1)
        (
        num_single="$(echo  "$ginfo" |  grep '[1-9][0-9][0-9](S)' | grep -o '[ ]' | wc -l)"
        nfg="$(echo  "$ginfo" |  grep  "[1-9][0-9][0-9](S)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}" |  bc )"
        w_jobs="$(echo "$ginfo" | sed -n '/waiting info./,$p' | grep -o '1:S' | wc -l)"
        echo $num_single $nfj $w_jobs
        ) > gs1.txt &

        (
        num_double="$(echo  "$ginfo2" |  grep '[1-9][0-9][0-9](D)' | grep -o '[ ]' | wc -l)"
        num_d_jobs="$(echo "${num_double}/2" | bc )"
        nfg="$(echo  "$ginfo2" |  grep  "[1-9][0-9][0-9](D)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/2" |  bc )"
        w_jobs="$(echo "$ginfo2" | sed -n '/waiting info./,$p' | grep -o '2:D' | wc -l)"
        echo $num_d_jobs $nfj $w_jobs
        ) > gs2.txt &

        (
        num_quadruple="$(echo  "$ginfo4" |  grep '[1-9][0-9][0-9](Q)' | grep -o '[ ]' | wc -l)"
        num_q_jobs="$(echo "${num_quadruple}/4" | bc )"
        nfg="$(echo  "$ginfo4" |  grep  "[1-9][0-9][0-9](Q)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/4" |  bc )"
        w_jobs="$(echo "$ginfo4" | sed -n '/waiting info./,$p' | grep -o '4:Q' | wc -l)"
        echo $num_q_jobs $nfj $w_jobs
        ) > gs3.txt &

        (
        num_eight="$(echo  "$ginfo8" |  grep '[1-9][0-9][0-9](E)' | grep -o '[ ]' | wc -l)"
        num_e_jobs="$(echo "${num_eight}/8" | bc )"
        nfg="$(echo  "$ginfo8" |  grep  "[1-9][0-9][0-9](E)" | grep -o '[ ]\|[x]' | wc -l)"
        nfj="$(echo "${nfg}/8" |  bc )"
        w_jobs="$(echo "$ginfo8" | sed -n '/waiting info./,$p' | grep -o '8:E' | wc -l)"
        echo $num_e_jobs $nfj $w_jobs
        ) > gs4.txt &

        wait

        IFS=" " read -ra r1 <<< "$(cat gs1.txt)" 
        IFS=" " read -ra r2 <<< "$(cat gs2.txt)" 
        IFS=" " read -ra r3 <<< "$(cat gs3.txt)"
        IFS=" " read -ra r4 <<< "$(cat gs4.txt)"  

        echo "---Type of Job for 1080Ti---         spare/total/waiting"
        echo "number of jobs for single gpu:       ${r1[0]}/${r1[1]}/${r1[2]}"
        echo "number of jobs for double gpus:      ${r2[0]}/${r2[1]}/${r2[2]}"
        echo "number of jobs for quadruple gpus:   ${r3[0]}/${r3[1]}/${r3[2]}"
        echo "number of jobs for eight gpus:       ${r4[0]}/${r4[1]}/${r4[2]}"
        ;;
    *)
        echo "Not valid argument!"
        exit 1
        ;;
esac

rm gs*.txt
end=`date +%s`
runtime=$((end-start))
echo "runtime:" $runtime"s"
