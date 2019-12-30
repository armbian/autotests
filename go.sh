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

display_alert "Try if we can login and send CTRL C" "$HOST" "info"
sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${HOST} "\x03" &>/dev/null
[[ $? -eq 1 ]] && armbian-first-login

x=1
SUM=0
while [ $x -le ${PASSES} ]
do
while ! ping -c1 $HOST &>/dev/null; do display_alert "Ping failed" "$(date  +%R:%S)" "wrn"; done ; START=$(date +%s); display_alert "Host found" "$(date  +%R:%S)" "info";


	TIMES[$x]=$(date +%s)
	# if wlan credentials are defined, let's check it first
	if [[ -n ${WLAN_ID} && $x -eq 1 && -n $(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli device | grep wifi") ]]; then
		check_wlan
	fi

	display_alert "Stressing [$x] for ${STRESS_TIME}s" "${HOST}" "info";
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "stress -q --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout ${STRESS_TIME}s"
	display_alert "Rebooting in 5 seconds" "${HOST}" "wrn"
	sleep 5
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "reboot"
	sleep 20
	x=$(( $x + 1 ))

done

x=2
while [ $x -lt ${PASSES} ]
do
	A=${TIMES[@]:$x:1}
	x=$(( $x + 1 ))
	B=${TIMES[@]:$x:1}
	[[ -z $B ]] && B=$(date +%s)
	echo $(( $B - $A ))
done
