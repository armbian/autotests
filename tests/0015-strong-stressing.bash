#!/bin/bash
source $SRC/lib/functions.sh
display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST} + ${STRESS_TIME}s" "info"
REMOTE_MEM=$(awk '{printf("%d",$2/1024/4)}' <<<$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "LC_ALL=C free -w 2>/dev/null | grep \"^Mem\""))
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "stress -q --cpu $(nproc) --io 4 --vm 2 --vm-bytes ${REMOTE_MEM}M --timeout ${STRESS_TIME}s"
