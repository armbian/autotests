#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Stress ${STRESS_TIME}s"
TEST_ICON="<img width=32 src=https://f0.pngfuel.com/png/586/784/fire-illustration-png-clip-art.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST} + ${STRESS_TIME}s" "info"
REMOTE_MEM=$(awk '{printf("%d",$2/1024/4)}' <<<$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "LC_ALL=C free -w 2>/dev/null | grep \"^Mem\""))
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "stress -q --cpu $(nproc) --io 4 --vm 2 --vm-bytes ${REMOTE_MEM}M --timeout ${STRESS_TIME}s"
if [[ $? -ne 0 ]]; then
	TEST_OUTPUT=":x:"
	else
	TEST_OUTPUT="<img width=16 src=https://github.githubassets.com/images/icons/emoji/unicode/2714.png>"
fi
