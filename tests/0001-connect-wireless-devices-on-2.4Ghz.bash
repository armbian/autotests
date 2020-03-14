#!/bin/bash

source $SRC/lib/functions.sh
display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${USER_HOST}" "info"

readarray -t array < <(get_device "^[wr].*" "")
for u in "${array[@]}"
do
	display_alert "... " "$u" "info"
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli con down $u &>/dev/null" # go down and
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli c del $u &>/dev/null" # delete if previous defined
	output=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_24}")
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_24}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	# retry once just in case
	[[ $? -ne 0 ]] && sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_24}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	output=$?
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli con modify $u wifi-sec.key-mgmt wpa-psk" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli con modify $u wifi-sec.psk ${WLAN_PASS_24}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} "nmcli con up $u" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	[[ $? -ne 0 && ${output} -eq 0 ]] && display_alert "Can't connect to ${WLAN_ID_24}" "$u" "wrn"
done
sleep 3
