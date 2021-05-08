#!/bin/bash
#gen_slm.sh p1 p2
#p1 name of job must
#p2 invoked commands
#p3 name of docker image optional default:bit:5000/deepo(can be customized to suit your needs)

#example
#must run under root_folder_of_source_code
#gen_slm.sh test_job "python ./execution.sh" "bit:5000/deepo"
#generate job_name.pbs job_name_exec.sh(execution script of invoked commands) job_name_record.txt(output of program)
#append_env.sh can be changed to suit your needs(or commented out)
#output path of job_name.out(.err) should be changed  to suit your needs
#example

#edited
#2021/04/25 11:24:30
#2021/05/02 11:17:30
#2021/05/08 17:26:30

if [ $# -le 1 ]
then
echo "ERROR:Not enough arguments!"
exit 1
fi  
echo "#!/bin/bash" > $1.slm
echo "#SBATCH --job-name=$1" >> $1.slm
echo "#SBATCH --gres=gpu:4" >> $1.slm
echo "#SBATCH --output=${HOME}/console/$1.out" >> $1.slm
echo "echo \"Submitted from:\"\$SLURM_SUBMIT_DIR\" on node:\"\$SLURM_SUBMIT_HOST" >>$1.slm
echo "\"Running on node \"\$SLURM_JOB_NODELIST" >>$1.slm
echo "echo \"Allocate Gpu Units:\"\$CUDA_VISIBLE_DEVICES"  >>$1.slm
echo "##program here ##" >>$1.slm

s_path=$(dirname "$BASH_SOURCE")
cat ${s_path}/append_env.sh > $1_exec.sh
sed -i "1a\a_HOME=${HOME}"  $1_exec.sh


chmod +x $1_exec.sh
cwd=$(pwd)
if [ $# -eq 2 ]
then
echo $2  >> $1_exec.sh
echo "startdocker -D /gdata/${USER} -P /ghome/${USER} -s ${cwd:13}/$1_exec.sh -u \"--privileged --ipc=host -v /gpub:/gpub -w=\"$cwd\"\" bit:5000/deepo"  '&>' $1_record.txt >> $1.slm
elif [ $# -eq 3 ]
then
echo $2  >> $1_exec.sh
echo "startdocker -D /gdata/${USER} -P /ghome/${USER} -s ${cwd:13}/$1_exec.sh -u \"--privileged --ipc=host -v /gpub:/gpub -w=\"$cwd\"\" $3" '&>' $1_record.txt >> $1.slm
else
echo "ERROR:Too many arguments!"
exit 2
fi
