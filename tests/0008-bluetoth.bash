#!/bin/bash
source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"
if [[ -n $BLUEDEV ]]; then
	resoult=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "hcitool name $BLUEDEV 2>/dev/null")
else
	return 0
fi
[[ -n $resoult ]] && display_alert "Bluetooth ping to your test device was succesfull" "$resoult" "info"
