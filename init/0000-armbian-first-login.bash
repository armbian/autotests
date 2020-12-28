#!/bin/bash

source $SRC/lib/functions.sh

display_alert "${x}. Trying" "$(date  +%R:%S) - $(mask_ip "$USER_HOST")" "info"


timeout 2m ping -c1 $USER_HOST &>/dev/null
if [[ $? -eq 0 ]]; then

#display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"
ssh-keygen -qf "$HOME/.ssh/known_hosts" -R "${USER_HOST}" > /dev/null 2>&1
sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${USER_HOST} "\x03" &>/dev/null

#echo $?
# since 20.08
if [[ $? -eq 127 ]]; then
display_alert "Conduct first login steps" "root/${PASS_ROOT} and ${USER_NORMAL}/${PASS_NORMAL}" "info"
MAKE_USER=$(expect -c "
        spawn sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${USER_HOST}
        set timeout 120
        expect \"New root password: \"
	send \"${PASS_ROOT}\r\"
        expect \"Repeat password: \"
        send \"${PASS_ROOT}\r\"
        expect \"Choose default system command shell: \"
        send \"2\r\"
	expect \"*your forename): \"
	send \"${USER_NORMAL}\r\"
        expect \"Create password:\"
        send \"${PASS_NORMAL}\r\"
        expect \"Repeat password:\"
        send \"${PASS_NORMAL}\r\"
        expect \"Please provide your real name (eg. John Doe): \"
        send \"${NAME_NORMAL}\r\"
        expect eof
        ")
        # Disable user creation: send \"\x03\"
        # display output
        echo "${MAKE_USER}" >> ${SRC}/logs/${USER_HOST}.txt
        echo "${MAKE_USER}" >> ${SRC}/logs/${USER_HOST}.log
fi

# before 20.08
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

# adjust repository
remoterelease=$(remote_exec "lsb_release -cs" "")
repository="deb http://$LOCALREPO ${remoterelease} main ${remoterelease}-utils ${remoterelease}-desktop"
#display_alert "Correct repository: ${repository}"
remote_exec "echo ${repository} > /etc/apt/sources.list.d/armbian.list" "-t"

if [[ $PREPAREONLY != yes ]]; then
display_alert "Run apt fixes just to make sure" "apt-get -f install"
remote_exec "apt-get -f install" "-t" "10m" &>/dev/null
display_alert "Updating packages" "apt update only"
remote_exec "chsh -s /bin/bash; apt -y purge armbian-config; apt update" "-t" "10m" &>/dev/null
display_alert "Installing stress, armbian-config, bluez-tools, iozone3 and sbc-bench" "test dependencies"
remote_exec "apt -qq -y install jq stress armbian-config bluez bluez-tools iozone3" "-t" "10m" &>/dev/null
remote_exec "wget -q -O /usr/local/bin/sbc-bench https://raw.githubusercontent.com/ThomasKaiser/sbc-bench/master/sbc-bench.sh; chmod +x /usr/local/bin/sbc-bench" "-t" "10m" &>/dev/null

# we will not wait for ideal load since load itself is more important than numbers
remote_exec "sed -i \"s/\tCheckLoad/\t#CheckLoad/\" /usr/local/bin/sbc-bench"
else
remote_exec "dpkg --configure -a --force-confold" "-t" "10m" &>/dev/null
fi

get_board_data
[[ -n $BOARD_NAME ]] && display_alert "$BOARD_NAME $BOARD_KERNEL $BOARD_UBOOT $BOARD_DISTRIBUTION_CODENAME $BOARD_IMAGE_TYPE" "$(date  +%R:%S) - $(mask_ip "$USER_HOST") Uptime: $BOARD_UPTIME" "info"
else
	display_alert "${x}. not accessible - $(mask_ip "$USER_HOST")" "$(date  +%R:%S)" "err"
fi
