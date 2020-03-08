#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
ssh-keygen -qf "/root/.ssh/known_hosts" -R "${HOST}" > /dev/null 2>&1
sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${HOST} "\x03" &>/dev/null
if [[ $? -eq 1 ]]; then
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
	# display output
	echo "${MAKE_USER}" | tee -a logs/${HOST}.log
fi
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "apt -qq -y install jq stress armbian-config" &>/dev/null
BOARD_NAME=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "cat /etc/armbian-release | grep BOARD_NAME | sed 's/\"//g' | cut -d "=" -f2")

# cat armbian release file to the logs
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "cat /etc/armbian-release | sed -e 's/^/'$(date  +%R:%S)' /' ">> ${SRC}/logs/${HOST}.txt 2>&1
