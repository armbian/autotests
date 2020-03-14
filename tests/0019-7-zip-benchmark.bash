#!/bin/bash
source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "armbianmonitor -z" >> ${SRC}/logs/${USER_HOST}.log | tee -a ${SRC}/logs/${USER_HOST}.txt
