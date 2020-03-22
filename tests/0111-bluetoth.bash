#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE=""
TEST_ICON="<img width=32 src=https://cdn4.iconfinder.com/data/icons/vecico-connectivity/288/bluetoothBG-512.png>"
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
	TEST_OUTPUT="<img width=16 src=https://github.githubassets.com/images/icons/emoji/unicode/2714.png>"
	else
	TEST_OUTPUT="<img width=16 src=https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/Philippines_road_sign_R3-1.svg/220px-Philippines_road_sign_R3-1.svg.png>"
fi
