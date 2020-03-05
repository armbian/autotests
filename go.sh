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
export SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source userconfig/configuration.sh
source lib/functions.sh

export PASS_ROOT USER_ROOT

if [[ -n $SUBNET ]]; then
	readarray -t array < <(nmap --open -sn ${SUBNET} | grep "ssh\|Nmap scan report" | grep -v "gateway" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
elif [[ -n $HOSTS ]]; then
	IFS=', ' read -r -a array <<< "$HOSTS"
else
	echo "\$HOST not defined. Exiting." && exit 1
fi



[[ -z $HOST_IPERF ]] && echo "\$HOST_IPERF not defined. Exiting." && exit 1

for HOST in "${array[@]}"; do
	rm -f logs/${HOST}.log
	export HOST
	run_tests
	[[ $? -ne 0 ]] && display_alert "Host failed" "$HOST" "err"
done
