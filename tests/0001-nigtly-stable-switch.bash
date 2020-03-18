#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Nightly or stable"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if (( $r % 2 )); then
	display_alert "Switch to stable builds" "$(date  +%R:%S)" "info"
#       sshpass -p ${PASS_ROOT} ssh -t ${USER_ROOT}@${USER_HOST} "LANG=C armbian-config main=System selection=Stable" &>/dev/null
else
	display_alert "Switch to nightly builds" "$(date  +%R:%S)" "info"
#       sshpass -p ${PASS_ROOT} ssh -t ${USER_ROOT}@${USER_HOST} "armbian-config main=System selection=Nightly" &>/dev/null
fi
