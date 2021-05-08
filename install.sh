#!/bin/bash

if ! [[ -v HOME ]];then
    echo "ERROR:HOME PATH environment variable is not set"
    exit 1
fi

source configuration.conf

if [ -d "$install_path" ];then
    find . -maxdepth 1 -not -name "install.sh" -name "*.sh"  | xargs cp -t $install_path
    if ! [ -d "${HOME}/console" ];then
    mkdir -p ${HOME}/console
    fi
else
    echo "ERROR:Installation path does not exist"
    exit 2
fi

if [ -f "${HOME}/.bash_aliases" ];then
    echo "alias ${gen_pbs_sh}=\"${install_path}/gen_pbs.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${gen_slm_sh}=\"${install_path}/gen_slm.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${job_by_name_sh}=\"${install_path}/job_by_name.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${gpu_summary_sh}=\"${install_path}/gpu_summary.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${sbatchd_sh}=\"${install_path}/sbatchd.sh\"" >> ${HOME}/.bash_aliases
else
    touch ${HOME}/.bash_aliases
    echo "alias ${gen_pbs_sh}=\"${install_path}/gen_pbs.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${gen_slm_sh}=\"${install_path}/gen_slm.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${job_by_name_sh}=\"${install_path}/job_by_name.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${gpu_summary_sh}=\"${install_path}/gpu_summary.sh\"" >> ${HOME}/.bash_aliases
    echo "alias ${sbatchd_sh}=\"${install_path}/sbatchd.sh\"" >> ${HOME}/.bash_aliases
fi
echo "Program has been successfully installed! You need to source .bash_aliases file before the first use.Please check README.md for use."
