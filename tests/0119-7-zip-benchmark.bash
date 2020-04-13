#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="7z bench"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/7zip.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME} @ $(mask_ip "$USER_HOST")" "info"
display_alert "7z bench" "${TEST_OUTPUT}" "info"
if [[ "$r" -le "${SBCBENCHPASS}" ]]; then
	TEST_OUTPUT=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "7-zip total" | awk '{print $NF}' | sed "s/,/\n/g" | awk '{ total += $1 } END { print total/NR }' | cut -d'.' -f1)
else
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"
fi
