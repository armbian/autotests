#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="7z bench"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/7zip.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME} @ $(mask_ip "$USER_HOST")" "info"
display_alert "7z bench" "${TEST_OUTPUT}" "info"

if [[ "$r" -le "${SBCBENCHPASS}" && -n "${SEVENZIP}" ]]; then
	TEST_OUTPUT=${SEVENZIP}
else
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
	display_alert "7z bench" "No data" "wrn"
fi
