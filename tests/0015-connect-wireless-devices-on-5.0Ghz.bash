#!/bin/bash

source $SRC/lib/functions.sh

TEST_TITLE="5Ghz"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/wifi.png>"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

readarray -t array < <(get_device "^[wr].*")

for u in "${array[@]}"
do
	display_alert "... " "$u" "info"
	remote_exec "nmcli con down $u &>/dev/null" # go down and
	remote_exec "nmcli c del $u &>/dev/null" # delete if previous defined
	output=$(remote_exec "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1)
	# retry once if it fails
        [[ $? -ne 0 ]] && remote_exec "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1

	remote_exec "nmcli con modify $u wifi-sec.key-mgmt wpa-psk" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	remote_exec "nmcli con modify $u wifi-sec.psk ${WLAN_PASS_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	remote_exec "nmcli con up $u" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
	if [[ $? -ne 0 ]]; then
		remote_exec "nmcli con down $u" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
		remote_exec "nmcli c del $u &>/dev/null" # delete if failed
		remote_exec "service network-manager reload"
		[[ -n $(echo "${output}" | grep succesfully) ]] && display_alert "Can't connect to ${WLAN_ID_50}" "$u" "wrn"
	fi
done
