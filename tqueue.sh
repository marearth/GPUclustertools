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
QSTAT_F=qstat_info.temp
##JOB_F=/dev/shm/job.tmp$$
echo -e "\nJobid\tUser\t   JobName\t\tReq_parm    Queue_time\t      S Run_time   Alloc_GPUS\n"
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

	echo -en ${jid}"\t"
	##EUSER=`cat $JOB_F |grep euser |awk -F'= ' '{print $2}'`
	EUSER=`get_xml euser`
	printf "%-10s " $EUSER
	##JOB_NAME=` cat $JOB_F |grep Job_Name |awk -F'=' '{print $2}'`
	JOB_NAME=`get_xml Job_Name`
	[ ${#JOB_NAME} -gt 20 ] && JOB_NAME=".."${JOB_NAME:0-18}
	printf "%-18s\t" ${JOB_NAME}
	##REQ_PARM=`cat $JOB_F |grep "Resource_List.nodes" |awk -F'= ' '{print $2}'`
	REQ_PARM=`get_xml nodes`
	printf "%-12s" $REQ_PARM
	
	##START_TIME=`cat $JOB_F |grep ctime|awk -F'= ' '{print $2}'`
	##START_TIME=`date "+%Y%m%d %H:%M:%S" -d "$START_TIME"`
	START_TIME=`get_xml ctime`
	START_TIME=`date "+%Y%m%d %T" -d @"$START_TIME"`
	printf "%-18s" "$START_TIME"
	##JOB_STATE=`cat $JOB_F |grep "job_state"|awk -F'= ' '{print $2}'`
	printf "%1s" "$JOBSTATE"
	#RUN_TIME=`cat $JOB_F |grep "resources_used.walltime"|awk -F'= ' '{print $2}'`
	RUN_TIME=`get_xml walltime resources_used`
	printf " %-10s " "$RUN_TIME"
	#echo -en `cat $JOB_F |grep exec_gpus |awk -F'=' '{print $2}'`
	#echo -en $GPUS
	#echo -en ${GPUS//+G1$CNUM-gpu/}
	echo -en ${GPUS//+$NODE-gpu/}
	echo
	
	n=$((n+1))
done	< $QSTAT_F

rm -f $QSTAT_F