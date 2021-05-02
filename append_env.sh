#!/bin/bash
a_LIBRARY_PATH=${a_HOME}/local/lib
a_LD_LIBRARY_PATH=${a_HOME}/local/lib
a_CPATH=${a_HOME}/local/include
a_PATH=${a_HOME}/local/bin:${a_HOME}/.local/bin

vs=`python -c 'import sys; print("{} {}".format(sys.version_info.major,sys.version_info.minor))'`
vs1=`echo $vs | cut -d ' ' -f 1`
vs2=`echo $vs | cut -d ' ' -f 2`
a_PYTHONPATH="${a_HOME}/.local/lib/python${vs1}.${vs2}/site-packages"

if [[ -v LIBRARY_PATH ]];then
  export LIBRARY_PATH=$LIBRARY_PATH:$a_LIBRARY_PATH
else
  export LIBRARY_PATH=$a_LIBRARY_PATH
fi
if [[ -v LD_LIBRARY_PATH ]];then
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$a_LD_LIBRARY_PATH
else
  export LD_LIBRARY_PATH=$a_LD_LIBRARY_PATH
fi
if [[ -v PATH ]];then
  export PATH=$PATH:$a_PATH
else
  export PATH=$a_PATH
fi
if [[ -v CPATH ]];then
  export CPATH=$CPATH:$a_CPATH
else
  export CPATH=$a_CPATH
fi
if [[ -v PYTHONPATH ]];then
  export PYTHONPATH=$PYTHONPATH:$a_PYTHONPATH
else
  export PYTHONPATH=$a_PYTHONPATH 
fi

export HOME=$a_HOME
