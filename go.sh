#!/bin/bash
#
# Simple autotest script.
#

apt install -y -qq jq expect sshpass nmap &>/dev/null
mkdir -p userconfig logs

# create sample configuration
if [[ ! -f userconfig/configuration.sh ]]; then
	cp lib/configuration.sh userconfig/configuration.sh
	echo "Setup finished. Edit userconfig/configuration.sh and run ./go.sh again!"
        exit
fi

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source userconfig/configuration.sh
source lib/functions.sh

# remove logs
rm -rf logs/*

[[ -n $EXCLUDE ]] && HOST_EXCLUDE="--exclude ${EXCLUDE}"

if [[ -n $SUBNET ]]; then
	readarray -t hostarray < <(nmap $HOST_EXCLUDE --open -sn ${SUBNET} | grep "ssh\|Nmap scan report" | grep -v "gateway" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
elif [[ -n $HOSTS ]]; then
	IFS=', ' read -r -a array <<< "$HOSTS"
else
	echo "\$HOST not defined. Exiting." && exit 1
fi

BOARD_NAMES=()
for HOST in "${hostarray[@]}"; do
	readarray -t array < <(find $SRC/init -maxdepth 2 -type f -name '*.bash' | sort)
	for u in "${array[@]}"
	do
		. $u
		BOARD_NAMES+=("$BOARD_NAME")
	done
done

x=0
for HOST in "${hostarray[@]}"; do
	rm -f logs/${HOST}.log
	run_tests
	x=$((x+1))
	[[ $? -ne 0 ]] && display_alert "Host failed" "$HOST" "err"
done
