#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Stress ${STRESS_TIME}s"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/fire.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S) + ${STRESS_TIME}s" "info"
REMOTE_MEM=$(awk '{printf("%d",$2/1024/4)}' <<<$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "LC_ALL=C free -w 2>/dev/null | grep \"^Mem\""))
remote_exec "stress -q --cpu $(nproc) --io 4 --vm 2 --vm-bytes ${REMOTE_MEM}M --timeout ${STRESS_TIME}s"
if [[ $? -ne 0 ]]; then
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/error.png>"
	else
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/checked.png>"
fi
