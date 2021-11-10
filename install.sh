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

cd $install_path
ln -s ./gen_pbs.sh ${gen_pbs_sh}
ln -s ./gen_slm_sh ${gen_slm_sh}
ln -s ./job_by_name.sh ${job_by_name_sh}
ln -s ./job_by_user.sh ${job_by_user_sh}
ln -s ./gpu_summary.sh ${gpu_summary_sh}
ln -s ./sbatchd.sh ${sbatchd_sh}

if [ -f "${HOME}/.bashrc" ];then
    echo " " >> ${HOME}/.bashrc
    echo " " >> ${HOME}/.bashrc
    echo "# begin:append execution PATH of GPUclustertools" >> ${HOME}/.bashrc
    echo "export PATH=${install_path}:\$PATH" >> ${HOME}/.bashrc
    echo "# end:append execution PATH of GPUclustertools" >> ${HOME}/.bashrc
else
    touch ${HOME}/.bashrc
    echo " " >> ${HOME}/.bashrc
    echo " " >> ${HOME}/.bashrc
    echo "# begin:append execution PATH of GPUclustertools" >> ${HOME}/.bashrc
    echo "export PATH=${install_path}:\$PATH" >> ${HOME}/.bashrc
    echo "# end:append execution PATH of GPUclustertools" >> ${HOME}/.bashrc
fi
echo "Program has been successfully installed! You need to source .bashrc file before the first use.Please check README.md for use."
