#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Report"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/link.png>"
[[ $DRY_RUN == true ]] && return 0
display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ -n ${SBCBENCHURL} && "$r" -le "${SBCBENCHPASS}" ]]; then
	TEST_OUTPUT="<a tarbet=_blank href=${SBCBENCHURL}><img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/link.png></a>"
else
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
	display_alert "SBC-bench URL" "No data" "wrn"
fi
