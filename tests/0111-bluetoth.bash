#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE=""
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/bluetooth.png>"
[[ $DRY_RUN == true ]] && return 0

unset resoult

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME}" "info"
if [[ -n $BLUEDEV ]]; then
	resoult=$(remote_exec "hcitool name $BLUEDEV 2>/dev/null")
else
	TEST_OUTPUT="n/a"
	return 0
fi

if [[ -n $resoult ]]; then 
	display_alert "Bluetooth ping to your test device was succesfull" "$resoult" "info"
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/checked.png>"
	else
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"
fi
