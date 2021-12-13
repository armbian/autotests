#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Temp"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/temp.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ -n ${GETTEMP} && "$r" -le "${SBCBENCHPASS}" ]]; then
	TEST_OUTPUT="${GETTEMP}"
else
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
	display_alert "Board temperature" "No data" "wrn"
fi
