#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Nightly or stable"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME}" "info"

remote_exec "apt update; apt -y purge armbian-config; apt -qq -y install armbian-config" "-t" &>/dev/null

if (( $r % 2 )); then
	display_alert "Switch to nightly builds" "$(date  +%R:%S)" "info"
	remote_exec "armbian-config main=System selection=Nightly" "-t" &>/dev/null
else
	display_alert "Switch to stable builds" "$(date  +%R:%S)" "info"
	remote_exec "LANG=C armbian-config main=System selection=Stable" "-t" &>/dev/null
fi
