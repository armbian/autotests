#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Reboot"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
display_alert "Rebooting in 3 seconds" "${BOARD_NAME}" "info"
sleep 3
remote_exec "reboot"
sleep 10
