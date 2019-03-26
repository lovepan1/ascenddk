#!/bin/bash
#
#   =======================================================================
#
# Copyright (C) 2018, Hisilicon Technologies Co., Ltd. All Rights Reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   1 Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#   2 Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
#   3 Neither the names of the copyright holders nor the names of the
#   contributors may be used to endorse or promote products derived from this
#   software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#   =======================================================================

# ************************Variable*********************************************

script_path="$( cd "$(dirname "$0")" ; pwd -P )"

remote_host=$1
presenter_view_app_name=$2
channel1=$3
channel2=$4

common_path="${script_path}/../../common"

. ${common_path}/utils/scripts/func_util.sh
. ${common_path}/utils/scripts/func_deploy.sh

function kill_remote_running()
{
    echo -e "\nrun.sh exit, kill ${remote_host}:ascend_videoanalysisapp running..."
    parse_remote_port
    iRet=$(IDE-daemon-client --host ${remote_host}:${remote_port} --hostcmd "for p in \`pidof ascend_videoanalysisapp\`; do { echo \"kill \$p\"; kill \$p; }; done")
    if [[ $? -ne 0 ]];then
        echo "ERROR: kill ${remote_host}:ascend_videoanalysisapp running failed, please login to kill it manually."
    else
        echo "$iRet in ${remote_host}."
    fi
    exit
}

trap 'kill_remote_running' 2 15

function main()
{
    check_ip_addr ${remote_host}
    if [[ $? -ne 0 ]];then
        echo "ERROR: invalid host ip, please check your command format: ./run_videoanalysisapp.sh host_ip presenter_view_app_name channel1 [channel2]."
        exit 1
    fi

    bash ${script_path}/prepare_param.sh ${remote_host} ${presenter_view_app_name} ${channel1} ${channel2}
    if [[ $? -ne 0 ]];then
        exit 1
    fi

    parse_remote_port

    echo "[Step] run ${remote_host}:ascend_videoanalysisapp..."

    #start app
    iRet=`IDE-daemon-client --host $remote_host:${remote_port} --hostcmd "cd ~/HIAI_PROJECTS/ascend_workspace/videoanalysisapp/out/;./ascend_videoanalysisapp"`
    if [[ $? -ne 0 ]];then
        echo "ERROR: excute ${remote_host}:./HIAI_PROJECTS/ascend_workspace/videoanalysisapp/out/ascend_videoanalysisapp failed, please check /var/log/syslog and board running log from IDE Log Module for details."
        exit 1
    fi
    exit 0
}

main
