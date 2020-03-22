#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="5Ghz"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"

sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "pkill iperf3;iperf3 -Ds --pidfile /var/run/iperf3"

readarray -t array < <(get_device "^[wr].*" "ip")

source $SRC/tests/include/iperf-on-all-interfaces.include