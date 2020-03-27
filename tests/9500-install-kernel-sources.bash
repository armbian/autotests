#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Sources"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/code.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME}" "info"

remote_exec "armbian-config main=Software selection=Source_install" "-t" &>/dev/null
if [[ $(remote_exec "[[ -d /usr/src/linux-source-\$(uname -r) ]] && echo \"OK\"") == "OK" ]]; then
	display_alert "Correct sources were installed" "" "info"
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/checked.png>"
	else
	display_alert "Wrong sources were installed" "" "err"
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/error.png>"
fi
