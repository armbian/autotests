#!/bin/bash

#--------------------------------------------------------------------------------------------------------------------------------
# Let's have unique way of displaying alerts
#--------------------------------------------------------------------------------------------------------------------------------
display_alert()
{
	local tmp=""
	[[ -n $2 ]] && tmp="[\e[0;33m $2 \x1B[0m]"

	case $3 in
		err)
		echo -e "[\e[0;31m error \x1B[0m] $1 $tmp"
		;;

		wrn)
		echo -e "[\e[0;35m warn \x1B[0m] $1 $tmp"
		;;

		ext)
		echo -e "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp"
		;;

		info)
		echo -e "[\e[0;32m o.k. \x1B[0m] $1 $tmp"
		;;

		*)
		echo -e "[\e[0;32m .... \x1B[0m] $1 $tmp"
		;;
	esac
}


function armbian-first-login()
{
	# clean keys
	# pass user creation to expect
	display_alert "Conduct first login steps" "root/${PASS_ROOT} and ${USER_NORMAL}/${PASS_NORMAL}" "info"

	MAKE_USER=$(expect -c "
	spawn sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${HOST}
	set timeout 10
	expect \"Current password:\"
	send \"1234\r\"
	expect \"New password:\"
	send \"${PASS_ROOT}\r\"
	expect \"Re-enter new password:\"
	send \"${PASS_ROOT}\r\"
	expect \"(eg. your forename):\"
	send \"${USER_NORMAL}\r\"
	expect \"New password:\"
	send \"${PASS_NORMAL}\r\"
	expect \"Retype new password:\"
	send \"${PASS_NORMAL}\r\"
	expect \"Name\"
	send \"${NAME_NORMAL}\r\"
	expect \"Room Number\"
	send \"${ROOM_NORMAL}\r\"
	expect \"Work Phone\"
	send \"${WORKPHONE_NORMAL}\r\"
	expect \"Home Phone\"
	send \"${HOMEPHONE_NORMAL}\r\"
	expect \"Other\"
	send \"${OTHER_NORMAL}\r\"
	expect \"information correct\"
	send \"Y\r\"
	expect eof
	")
	# Disable user creation: send \"\x03\"

	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "apt -y install jq stress"

	# display output
	echo "${MAKE_USER}"

}


function check_wlan
{

	# clean keys
	#ssh-keygen -f "/root/.ssh/known_hosts" -R ${HOST} > /dev/null 2>&1

	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli d wifi connect ${WLAN_ID} password ${WLAN_PASS}" &>/dev/null
	if [[ $? -eq 0 ]]; then
		display_alert "Connected to wireless" "${WLAN_ID}"

		# get wireless ip
		local GETWLANIP=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli -t -f UUID,TYPE,DEVICE connection show --active | grep wireless | rev | cut -d ':' -f1 | rev | xargs ifconfig | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'")
		display_alert "Get wireless ip" "${GETWLANIP}"

		# disable wired networking
		sshpass -p ${PASS_ROOT} ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${GETWLANIP} "nmcli -t -f UUID,TYPE connection | grep ethernet | sed 's/:.*$//' | xargs nmcli connection down" &>/dev/null
		display_alert "Disable wired networking" "${HOST}"

		# do the test
		display_alert "Make WLAN performance test" "${GETWLANIP} -> ${HOST_IPERF}"
		sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${GETWLANIP} "iperf3 -c ${HOST_IPERF} -t 5 -J | jq -r '.intervals' | grep bits_per_second | awk '{print \$2}' | awk '{printf(\"%.0f\n\", \$1)}' | awk '{\$1/=1000000;printf \"%.0f MBits/s\n\",\$1}' | sed -n 'p;n'"

		# re-enable wired networking
		sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${GETWLANIP} "nmcli -t -f UUID,TYPE connection | grep ethernet | sed 's/:.*$//' | xargs nmcli connection up" &>/dev/null
		display_alert "Enable wired networking" "${HOST}"

		 # disable WLAN networking
                sshpass -p ${PASS_ROOT} ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${HOST} "nmcli -t -f UUID,TYPE connection | grep wireless | sed 's/:.*$//' | xargs nmcli connection down" &>/dev/null
                display_alert "Disable WLAN networking" "${GETWLANIP}"

		# do the test
                display_alert "Make Ethernet performance test" "${HOST} -> ${HOST_IPERF}"
                sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "iperf3 -c ${HOST_IPERF} -t 5 -J | jq -r '.intervals' | grep bits_per_second | awk '{print \$2}' | awk '{printf(\"%.0f\n\", \$1)}' | awk '{\$1/=1000000;printf \"%.0f MBits/s\n\",\$1}' | sed -n 'p;n'"

	else
		display_alert "connecting to wireless" "${WLAN_ID}" "err"
	fi

}
