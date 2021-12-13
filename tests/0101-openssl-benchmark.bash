#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="AES-256"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/ssl.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME} @ $(mask_ip "$USER_HOST")" "info"

if [[ "$r" -le "${SBCBENCHPASS}" && -n "${AES128}" ]]; then

	TEST_OUTPUT=${AES128}
	display_alert "OpenSSL bench" "AES-256 16byte ${TEST_OUTPUT}" "info"

	else

	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
	display_alert "OpenSSL bench" "No data" "wrn"

fi
