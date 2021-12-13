#!/bin/bash

source $SRC/lib/functions.sh

TEST_TITLE="5Ghz"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/wifi.png>"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

readarray -t array < <(get_device "^[wr].*")

for u in "${array[@]}"
do
	FREQ5GHZ=$(remote_exec "iwlist $u freq | grep \" 5.\" | wc -l")
	GETUUID=$(remote_exec "nmcli -f UUID,DEVICE c show --active | grep $u | awk '{print \$1}'")	
	[[ -n $GETUUID && ${#array[@]} -gt 1 ]] && remote_exec "nmcli con down $GETUUID &>/dev/null" # go down and
	[[ -n $GETUUID && ${#array[@]} -gt 1 ]] && remote_exec "nmcli c del $GETUUID &>/dev/null" # delete if previous defined
	if [[ "$FREQ5GHZ" -gt 1 ]]; then
		display_alert "Connecting ... " "$u" "info"
		output=$(remote_exec "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1)
		output=$?
		# retry once just in case
		[[ $? -ne 0 ]] && sleep 2 && remote_exec "nmcli c add type wifi con-name $u ifname $u ssid ${WLAN_ID_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1 && output=$?
		remote_exec "nmcli con modify $u wifi-sec.key-mgmt wpa-psk" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
		remote_exec "nmcli con modify $u wifi-sec.psk ${WLAN_PASS_50}" >> ${SRC}/logs/${USER_HOST}.txt 2>&1	
		remote_exec "nmcli con up $u" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
		[[ $? -ne 0 && ${output} -eq 0 ]] && display_alert "Can't connect to ${WLAN_ID_50}" "$u" "wrn"
	fi
done
# clean all connections to make sure you start cleanly next time
#remote_exec "rm -rf /etc/NetworkManager/*" >> ${SRC}/logs/${USER_HOST}.txt 2>&1
