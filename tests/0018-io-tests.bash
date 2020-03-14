#!/bin/bash
source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"
TEMP=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "iozone -e -a -s 100M -r 16384k -i 0 -i 1 -i 2 | tail -3 | head -1")

READ=$(echo $(echo $TEMP | awk '{print $7}') / 1000 | bc | awk '{printf "%.0f MBits/s\n",$1}')
WRITE=$(echo $(echo $TEMP | awk '{print $8}') / 1000 | bc | awk '{printf "%.0f MBits/s\n",$1}')

display_alert "Max random roofs throughput on 16Mb files" "Read: $READ - Write: $WRITE" "info"

sleep 2

TEMP=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "cd /tmp; iozone -e -a -s 100M -r 16384k -i 0 -i 1 -i 2 | tail -3 | head -1")

READ=$(echo $(echo $TEMP | awk '{print $7}') / 1000 | bc | awk '{printf "%.0f MBits/s\n",$1}')
WRITE=$(echo $(echo $TEMP | awk '{print $8}') / 1000 | bc | awk '{printf "%.0f MBits/s\n",$1}')

display_alert "Max random memory throughput on 16Mb files" "Read: $READ - Write: $WRITE" "info"
