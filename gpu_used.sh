#!/bin/bash

NODE_FIX_LEN=2            
get_xml(){
	p=$1
	p2h=${2:+\<$2\>}
	p2t=${2:+\</$2\>}
	if [[ $JOB_S =~ $p2h.*\<$p\>(.*)\</$p\>.*$p2t ]];then 
		echo ${BASH_REMATCH[1]}
	fi
	#sed -n 's/.*<resources_used>.*walltime>\(.*\)<\/walltime>.*<\/resources_used>.*/\1/p'
}

NodeNum=25
n=0
QSTAT_F=gpu_used_info.temp
##JOB_F=/dev/shm/job.tmp$$
# echo -e "\nJobid\tUser\t   JobName\t\tReq_parm    Queue_time\t      S Run_time   Alloc_GPUS\n"
PARM=${1:+"-u "$1}
/usr/local/bin/qstat $PARM |grep Ghead|grep -v "Ghead:"|cut -d' ' -f1|cut -d'.' -f1 > $QSTAT_F
while read jid
do
	##/usr/local/bin/qstat -f  $jid > $JOB_F 2>/dev/null
	JOB_S=$(/usr/local/bin/qstat -f -x  $jid 2>/dev/null)
	[ $? -ne 0 ] && continue

	##JOBSTATE=`cat $JOB_F|awk -F'= ' '/job_state/{print $2}'`
	JOBSTATE=`get_xml job_state`
	GPUS="";
          GPUS=`get_xml exec_gpus`
	  NODE=${GPUS%%-*}
	  ##NODE=`cat $JOB_F |grep "exec_gpus"|awk -F'= ' '{print $2}'|cut -d'-' -f1`
	  #GPUS=`cat $JOB_F |grep "exec_gpus"|awk -F'= ' '{print $2}'`
	  ##GPUS=`cat $JOB_F |awk -F'= ' '/exec_gpus/{tt=$2;if(length($2)==62){getline;gsub(/[[:blank:]]*/,"");printf "%s%s\n",tt,$0} else print tt;}'`
	  CNUM=${NODE:$NODE_FIX_LEN}
	  NUM=`printf "%g" $CNUM`

	if [ "x"$JOBSTATE == "xR" ];then
	  for i in `echo $GPUS |sed  "s/$NODE-gpu\///g"|sed "s/+/ /g"` ;do eval GPU${NUM}[$i]=1; done
	fi	
	n=$((n+1))
done	< $QSTAT_F


echo -e "\nGPU used detail:"
echo "--1080Ti--  Valid type: 1:S  2:D  4:Q  8:E  ----"
echo "         0  1  2  3  4  5  6  7"
#for ((i=1;i<=$NodeNum;i++))
for i in {1..6} {8..20} {22..25}
do
   #echo -ne "GPU10$i:\t"
   #printf "Gpu1%02d:\t" $i
   NODEI=`printf "G1%02d" $i`
   PROP=`/usr/local/bin/pbsnodes -x  $NODEI|sed -n 's/.*<properties>\(.*\)<\/properties>.*/\1/p'`
   printf "1%02d($PROP):\t" $i 

   AVGPU=`pbsnodes $NODEI|grep gpus |cut -d'=' -f2`
   for((j=0;j<8;j++))
    do
     [ $j -ge $AVGPU ] && break
     #[ $i -eq 8 ] && [ $j -ge 7 ] && break
     #[ $i -eq 21 ] && [ $j -ge 7 ] && break
     #[ $i -eq 22 ] && [ $j -ge 7 ] && break
     #[ $i -eq 13 ] && [ $j -ge 7 ] && break
     eval tmp=\${GPU$i[$j]}
     #[ $j == "2" ] && echo -ne " | "
     [ "x"$tmp == "x1" ] && echo -n "[x]" || echo -n "[ ]" 
    done
    echo
done
echo ""
echo "--2080Ti--  Valid type: 1:s  2:d  4:q  8:e ----"
echo "         0  1  2  3  4  5  6  7 "
for i in {71..86}
do

   NODEI=`printf "G1%02d" $i`
   PROP=`/usr/local/bin/pbsnodes -x  $NODEI|sed -n 's/.*<properties>\(.*\)<\/properties>.*/\1/p'`
   printf "1%02d($PROP):\t" $i

   AVGPU=`pbsnodes $NODEI|grep gpus |cut -d'=' -f2`
   for((j=0;j<8;j++))
    do
     [ $j -ge $AVGPU ] && break
     #[ $i -le 32 ] && [ $j -ge 4 ] && break
     #[ $i -le 37 ] && [ $j -ge 8 ] && break
     #[ $i -eq 39 ] && [ $j -eq 15 ] && break
     #[ $i -eq 44 ] && [ $j -ge 8 ] && break
     eval tmp=\${GPU$i[$j]}
     [ "x"$tmp == "x1" ] && echo -n "[x]" || echo -n "[ ]"
    done
    echo
done

echo ""
echo "--3090/3080Ti-- Valid type: 1:A  2:B  4:C  8:F ----"
echo "         0  1  2  3  4  5  6  7 "
for i in 7 21 {31..38}
do

   NODEI=`printf "G1%02d" $i`
   PROP=`/usr/local/bin/pbsnodes -x  $NODEI|sed -n 's/.*<properties>\(.*\)<\/properties>.*/\1/p'`
   printf "1%02d($PROP):\t" $i

   AVGPU=`pbsnodes $NODEI|grep gpus |cut -d'=' -f2`
   for((j=0;j<8;j++))
    do
     [ $j -ge $AVGPU ] && break
     #[ $i -eq 44 ] && [ $j -ge 8 ] && break
     eval tmp=\${GPU$i[$j]}
     [ "x"$tmp == "x1" ] && echo -n "[x]" || echo -n "[ ]"
    done
    echo
done

echo -e "\nTotal $n jobs."

#echo -e "\n1080Ti Gpu node:{G101-G125}, K80 Gpu node:{G131-G144}"
echo  " "
rm -f $QSTAT_F