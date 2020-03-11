#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
display_alert "Rebooting in 3 seconds" "${HOST}" "info"
sleep 3
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "reboot" &>/dev/null
sleep 3
i=0
# return error if machine does not come back after 10 seconds
echo -en "[\e[0;32m o.k. \x1B[0m] "
while ping -c1 $HOST &>/dev/null; do echo -n "."; sleep 2; i=$(( $i + 1 )); [[ $i -gt 10 ]] && return 1; done
i=0
echo ""
