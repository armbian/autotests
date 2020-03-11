#!/bin/bash
return 0
source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${HOST}" "info"
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "armbianmonitor -z" >> ${SRC}/logs/${HOST}.log | tee -a ${SRC}/logs/${HOST}.txt
