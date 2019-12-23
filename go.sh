#!/bin/bash
#
# Simple autotest script.
#

apt install -y -qq expect sshpass &>/dev/null
mkdir -p userconfig

# create sample configuration
if [[ ! -f userconfig/configuration.sh ]]; then
	cp lib/configuration.sh userconfig/configuration.sh
fi

source userconfig/configuration.sh
source lib/functions.sh

[[ -z $HOST ]] && echo "\$HOST not defined. Exiting." && exit 1
[[ -z $HOST_IPERF ]] && echo "\$HOST_IPERF not defined. Exiting." && exit 1

# needed if we haven't login yet
get_keys

ssh-keygen -f "/root/.ssh/known_hosts" -R ${HOST}
sshpass -p 1234 ssh ${USER_ROOT}@${HOST} "ls"
# if password is still default, change passwd and create new user
[[ $? -eq 1 ]] && armbian-first-login

x=1
while [ $x -le ${PASSES} ]
do
while ! ping -c1 $HOST &>/dev/null; do echo "Ping Fail - `date`"; done ; echo "Host Found - `date`" ;

	# if wlan credentials are defined, let's check it first
	if [[ -n ${WLAN_ID} && $x -eq 1 ]]; then
		check_wlan
	fi

	echo "Stressing $HOST"
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "apt -y install stress ; stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 60s"

	echo "Rebooting $HOST"
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "reboot"
	sleep 20
	x=$(( $x + 1 ))

done
echo "Passed"
