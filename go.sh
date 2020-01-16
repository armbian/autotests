#!/bin/bash
#
# Simple autotest script.
#

apt install -y -qq expect sshpass &>/dev/null
mkdir -p userconfig logs

# create sample configuration
if [[ ! -f userconfig/configuration.sh ]]; then
	cp lib/configuration.sh userconfig/configuration.sh
fi

source userconfig/configuration.sh
source lib/functions.sh

[[ -z $HOSTS ]] && echo "\$HOST not defined. Exiting." && exit 1
[[ -z $HOST_IPERF ]] && echo "\$HOST_IPERF not defined. Exiting." && exit 1


IFS=', ' read -r -a array <<< "$HOSTS"
for HOST in "${array[@]}"; do
	rm logs/${HOST}.log
	run_tests
done
