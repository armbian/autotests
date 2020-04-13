#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="AES-256 16byte"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/ssl.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME} @ $(mask_ip "$USER_HOST")" "info"

if [[ "$r" -le "${SBCBENCHPASS}" ]]; then

	TEST_OUTPUT=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "aes-256" | head -1 | cut -d' ' -f2- | awk '{print $1}' | cut -d'.' -f1)
	display_alert "OpenSSL bench" "AES-256 16byte ${TEST_OUTPUT}" "info"

	else

	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"

fi
