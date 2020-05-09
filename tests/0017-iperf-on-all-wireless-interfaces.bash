#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="5Ghz"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

remote_exec "pkill iperf3; sleep 2; iperf3 -Ds --pidfile /var/run/iperf3"

readarray -t array < <(get_device "^[wr].*" "ip")

if [[ "$FREQ5GHZ" -gt 1 ]]; then
source $SRC/tests/include/iperf-on-all-interfaces.include
else
TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"
fi
