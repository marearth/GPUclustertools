#!/bin/bash
#usage:gen_pbs.sh p1 p2 p3 p4
#parameter p1 indicates the job name of pbs file  must
#parameter p2 indicates the number and type of used gpus optional (1S 2D 4Q 1s 2d 4q 8e 1A 2B 4C 8F) default: 1S 
#parameter p3 indicates invoked script    optional  default: empty
#parameter p4 indicates invoked image     optional default: bit:5000/deepo

#example:
#run under root_folder_of_source_code 
#gen_pbs.sh test_job  1S "python ./execution.py"  "bit:5000/deepo"
#generate job_name.pbs job_name_exec.sh(execution script of invoked commands) job_name_record.txt(output of program)
#append_env.sh can be changed to suit your needs(or commented out)
#output path of job_name.out(.err) should be changed to suit your needs
#example

#changes
#changes
#edited in 2018/08/08 15:13:55
#edited in 2021/03/20 11:10:00
#edited in 2021/04/25 10:58:00
#edited in 2021/05/02 11:14:30

echo "#PBS -N $1" > $1.pbs
echo "#PBS -o ${HOME}/console/$1.out" >> $1.pbs
echo "#PBS -e ${HOME}/console/$1.err" >> $1.pbs
if [ $# -ge 2 ]
then
case $2 in
'1S') echo "#PBS -l nodes=1:gpus=1:S" >> $1.pbs;;
'2D') echo "#PBS -l nodes=1:gpus=2:D" >> $1.pbs;;
'4Q') echo "#PBS -l nodes=1:gpus=4:Q" >> $1.pbs;;
'8e') echo "#PBS -l nodes=1:gpus=8:e" >> $1.pbs;;
'1s') echo "#PBS -l nodes=1:gpus=1:s" >> $1.pbs;;
'2d') echo "#PBS -l nodes=1:gpus=2:d" >> $1.pbs;;
'4q') echo "#PBS -l nodes=1:gpus=4:q" >> $1.pbs;;
'1A') echo "#PBS -l nodes=1:gpus=1:A" >> $1.pbs;;
'2B') echo "#PBS -l nodes=1:gpus=2:B" >> $1.pbs;;
'4C') echo "#PBS -l nodes=1:gpus=4:C" >> $1.pbs;;
'8F') echo "#PBS -l nodes=1:gpus=8:F" >> $1.pbs;;
*)
   echo "Not avaliable gpus"
   exit 1
   ;;
esac 
fi
if [ $# -eq 1 ]
then
echo "#PBS -l nodes=1:gpus=1:S" >> $1.pbs
fi
echo "#PBS -r y" >> $1.pbs
echo 'cd  $PBS_O_WORKDIR'  >> $1.pbs
echo "echo Time is \$('date')">> $1.pbs
echo 'echo Directory is $PWD'  >> $1.pbs
echo "echo This job runs on following nodes:" >> $1.pbs
echo "echo -n \"Node:\"" >> $1.pbs
echo 'cat $PBS_NODEFILE' >> $1.pbs
echo "echo -n \"Gpus:\"" >> $1.pbs
echo 'cat $PBS_GPUFILE' >> $1.pbs
echo "echo \"CUDA_VISIBLE_DEVICES:\"\$CUDA_VISIBLE_DEVICES"  >>$1.pbs 

cat ${HOME}/.local/bin/append_env.sh > $1_exec.sh
sed -i "1a\a_HOME=${HOME}"  $1_exec.sh

chmod +x $1_exec.sh
cwd=$(pwd)
if [ $# -eq 3 ]
then
echo $3  >> $1_exec.sh
echo "startdocker -D /gdata/${USER} -P /ghome/${USER} -s ${cwd:13}/$1_exec.sh -u \"--privileged --ipc=host -v /gpub:/gpub -w=\"$cwd\"\" bit:5000/deepo" '&>' $1_record.txt >> $1.pbs
elif [ $# -eq 4 ]
then
echo $3  >> $1_exec.sh
echo "startdocker -D /gdata/${USER} -P /ghome/${USER} -s ${cwd:13}/$1_exec.sh -u \"--privileged --ipc=host -v /gpub:/gpub -w=\"$cwd\"\" $4" '&>' $1_record.txt >> $1.pbs
else
echo "startdocker -D /gdata/${USER} -P /ghome/${USER} -s ${cwd:13}/$1_exec.sh -u \"--privileged --ipc=host -v /gpub:/gpub -w=\"$cwd\"\" bit:5000/deepo" '&>' $1_record.txt >> $1.pbs
fi
