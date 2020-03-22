#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="memory"
TEST_ICON=""
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
TEMP=$(remote_exec "cd /tmp; iozone -e -a -s 100M -r 16384k -i 0 -i 1 -i 2 | tail -3 | head -1")

READ=$(echo $(echo $TEMP | awk '{print $7}') / 1000 | bc)
WRITE=$(echo $(echo $TEMP | awk '{print $8}') / 1000 | bc)

display_alert "Max random memory throughput on 16Mb files" "Read: $READ MBits/s - Write: $WRITE MBits/s" "info"
TEST_OUTPUT+="$READ - $WRITE"
