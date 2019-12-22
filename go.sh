#!/bin/bash
#
# Simple autotest script.
#

source lib/configuration.sh
source lib/functions.sh

[[ -z $HOST ]] && echo "\$HOST not defined. Exiting." && exit 1
[[ -z $HOST_IPERF ]] && echo "\$HOST_IPERF not defined. Exiting." && exit 1

x=1
while [ $x -le ${PASSES} ]
do
while ! ping -c1 $HOST &>/dev/null; do echo "Ping Fail - `date`"; done ; echo "Host Found - `date`" ;
	
	# if wlan credentials are defined, let's check it first
	if [[ -n ${WLAN_ID} && $x -eq 1 ]]; then
		check_wlan
	fi
	
	echo "Stressing $HOSTNAME"
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "stress --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 60s"
	
	echo "Rebooting $HOSTNAME"
    sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "reboot"
	sleep 20
	x=$(( $x + 1 ))

done
echo "Passed"
