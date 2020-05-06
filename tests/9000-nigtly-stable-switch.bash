#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Nightly or stable"
TEST_SKIP="true"
[[ $DRY_RUN == true || $BSPSWITCH == "no" ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAME}" "info"

remote_exec "apt update; apt -y purge armbian-config; apt -qq -y install armbian-config" "-t" &>/dev/null

case "$r" in
1)
	display_alert "Switch to nightly builds, branch current" "................................." "info"
	remote_exec "armbian-config main=System selection=Nightly branch=current" "-t" "10m" &>/dev/null
;;
22222)
	display_alert "Switch to nightly builds, branch dev" "................................." "info"
	remote_exec "armbian-config main=System selection=Nightly branch=dev" "-t" "10m" &>/dev/null
;;
9999)
	display_alert "Switch to stable builds, branch dev" "................................." "info"
	remote_exec "armbian-config main=System selection=Stable branch=dev" "-t" "10m" &>/dev/null
;;
*)
	display_alert "Switch to stable builds, branch current" "................................." "info"
	remote_exec "armbian-config main=System selection=Stable branch=current" "-t" "10m" &>/dev/null
;;
esac
sleep 20
