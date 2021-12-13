#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Throttling"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/fire.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ "$r" -le "${SBCBENCHPASS}" && -n "${THROTTLING}" ]]; then
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/exclamation.png>"
	else
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
fi
