#!/bin/bash

function get_keys()
{

	local GET_KEYS=$(expect -c "
        spawn ssh ${USER_ROOT}@${HOST}
        set timeout 3
        expect \"Are you sure you want to continue connecting (yes/no)?\"
        send \"yes\r\"
	expect eof
        ")
	echo $GET_KEYS
}

function armbian-first-login()
{
	# clean keys
	get_keys
	# pass user creation to expect
	MAKE_USER=$(expect -c "
	spawn ssh ${USER_ROOT}@${HOST}
	set timeout 10
	expect \"password:\"
	send \"1234\r\"
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
	#expect eof
	")
	# Disable user creation: send \"\x03\"

	# display output
	echo "${MAKE_USER}"

}


function check_wlan
{

	# clean keys
	ssh-keygen -f "/root/.ssh/known_hosts" -R ${HOST} > /dev/null 2>&1

	# connect wireless
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli d wifi connect ${WLAN_ID} password ${WLAN_PASS}"

	# get wireless ip
	local GETWLANIP=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli -t -f UUID,TYPE,DEVICE connection show --active | grep wireless | rev | cut -d ':' -f1 | rev | xargs ifconfig | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'")

	# disable wired networking
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${GETWLANIP} "nmcli -t -f UUID,TYPE connection | grep ethernet | sed 's/:.*$//' | xargs nmcli connection down"

	# do the test
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@$GETWLANIP "iperf3 -c ${HOST_IPERF}"

	# re-enable wired networking
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${GETWLANIP} "nmcli -t -f UUID,TYPE connection | grep ethernet | sed 's/:.*$//' | xargs nmcli connection up"

}
