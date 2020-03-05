#!/bin/bash

source $SRC/lib/functions.sh
display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

readarray -t array < <(get_device "^[wr].*" "noip")

for u in "${array[@]}"
do
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID}" >> ${SRC}/logs/${HOST}.txt 2>&1
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli con modify $u wifi-sec.key-mgmt wpa-psk" >> ${SRC}/logs/${HOST}.txt 2>&1
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli con modify $u wifi-sec.psk ${WLAN_PASS}" >> ${SRC}/logs/${HOST}.txt 2>&1
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli con up $u" >> ${SRC}/logs/${HOST}.txt 2>&1
	[[ $? -ne 0 ]] && display_alert "Something went wrong with $u - check logs" "$u" "wrn"
	sleep 3
done
