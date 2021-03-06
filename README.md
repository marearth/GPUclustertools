## GPUclustertools
Here are efficient tools to make use of Torque platform or slurm platform easily.
## Installation
Run the following command in shell
```
./install.sh
```
Before installation ,you can configure installation path and aliases of invoked scripts in the configuration.conf file.
## Usage
For the first use,you should __source ~/.bashrc__ in the current shell after installation, which will append the installation path to PATH 
environment variable.

Generate pbs or slm format configuration file and relevant files with one line of code. You can check source code for detailed information.
```
#Generate pbs configuration file and relevant files
gpbs job_name type_of_used_gpus(e.g.,2B) invoked_script invoked_image
#exmaple
gpbs test_gpu 2B "python ./execution.sh" "bit:5000/deepo"
#Generate slm configuration file and relevant files
gslm job_name invoked_script invoked_image
#example
gslm test_gpu  "python ./execution.sh" "bit:5000/deepo"
```
Submit slm file in a delayed time to make GPU rest for a while. RUN the following code.
```
sbd name_of_slm.slm max_number_of_available_jobs interval_time_between_scanning
#exmaple
sbd test_gpu.slm &
```
Check statistical information of state of jobs for specified type of GPU. RUN the following code.
```
#encoded number of type of GPU,e.g.,3--->3090RTX,2--->2080TI,1---->1080Ti
gcheck encoded_number
#example
gcheck 3
```
Following picture shows the snapshot result of gcheck command.

![snapshot_gcheck_result](https://github.com/marearth/GPUclustertools/blob/main/gcheck_snapshot.png)

Check real GPU consumption by job of name. RUN the following code.

```
jbn name_of_job user_name(optional)
#example
jbn cost_multi xugk
```
Following picture shows the snapshot result of jbn command.

![snapshot_jbn_result](https://github.com/marearth/GPUclustertools/blob/main/jbn_snapshot_result.png)


Check submitted jobs of user in a relatively quick way. RUN the following code.

```
jbu user_name(optional)
#example
jbu xugk
```
Following picture shows the snapshot result of jbu command.

![snapshot_jbu_result](https://github.com/marearth/GPUclustertools/blob/main/jbu_snapshot_result.png)
