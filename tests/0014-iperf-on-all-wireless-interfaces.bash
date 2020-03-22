#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="2.4Ghz"
TEST_ICON="<img width=32 src=https://cdn4.iconfinder.com/data/icons/ionicons/512/icon-wifi-32.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

remote_exec "pkill iperf3;iperf3 -Ds --pidfile /var/run/iperf3"

readarray -t array < <(get_device "^[wr].*" "ip")

source $SRC/tests/include/iperf-on-all-interfaces.include
