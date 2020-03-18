#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Lan"
TEST_ICON="<img width=32 src=https://www.pngkey.com/png/detail/856-8562696_ethernet-on-icon-rj45-icon.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"

sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "pkill iperf3;iperf3 -Ds --pidfile /var/run/iperf3"

readarray -t array < <(get_device "^bond.*|^[e].*|^br.*|^lt.*|^umts.*|^lan.*" "ip")

source $SRC/tests/include/iperf-on-all-interfaces.include
