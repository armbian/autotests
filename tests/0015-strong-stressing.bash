#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S) + ${STRESS_TIME}s" "info"
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "stress -q --cpu $(nproc) --io 4 --vm 2 --vm-bytes 128M --timeout ${STRESS_TIME}s"
