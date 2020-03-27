#!/bin/bash

source $SRC/lib/functions.sh

#display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
ssh-keygen -qf "$HOME/.ssh/known_hosts" -R "${USER_HOST}" > /dev/null 2>&1
sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${USER_HOST} "\x03" &>/dev/null
if [[ $? -eq 1 ]]; then
	# clean keys
	# pass user creation to expect
	display_alert "Conduct first login steps" "root/${PASS_ROOT} and ${USER_NORMAL}/${PASS_NORMAL}" "info"

	MAKE_USER=$(expect -c "
	spawn sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${USER_HOST}
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
	echo "${MAKE_USER}" >> ${SRC}/logs/${USER_HOST}.txt
	echo "${MAKE_USER}" >> ${SRC}/logs/${USER_HOST}.log
fi

remote_exec "chsh -s /bin/bash; apt -y purge armbian-config; apt update; apt -qq -y install jq stress armbian-config bluez-tools iozone3" "-t" &>/dev/null

get_board_data
[[ -n $BOARD_NAME ]] && display_alert "${x}. $BOARD_NAME $BOARD_KERNEL $BOARD_IMAGE_TYPE" "$(mask_ip "$USER_HOST")" "info"
