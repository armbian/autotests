#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
display_alert "Rebooting in 5 seconds" "${HOST}" "wrn"
sleep 5
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "reboot"
sleep 10
