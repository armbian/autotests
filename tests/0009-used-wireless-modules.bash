#!/bin/bash

source $SRC/lib/functions.sh
display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

readarray -t array < <(get_device "^[wr].*" "interfaces")

for u in "${array[@]}"
do
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli | sed -nE \"/^$u.*/,/wifi /p\" | head -3 | tail -1 | awk -F'(' '{print \$2}' | awk -F')' '{print \$1}'"	
done
