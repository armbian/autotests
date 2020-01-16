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
		echo -e "[\e[0;31m error \x1B[0m] $1 $tmp" | tee -a logs/${HOST}.log
		;;

		wrn)
		echo -e "[\e[0;35m warn \x1B[0m] $1 $tmp" | tee -a logs/${HOST}.log
		;;

		ext)
		echo -e "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp" | tee -a logs/${HOST}.log
		;;

		info)
		echo -e "[\e[0;32m o.k. \x1B[0m] $1 $tmp" | tee -a logs/${HOST}.log
		;;

		*)
		echo -e "[\e[0;32m .... \x1B[0m] $1 $tmp" | tee -a logs/${HOST}.log
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
	# display output
	echo "${MAKE_USER}" | tee -a logs/${HOST}.log


}


function check_wlan
{

	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli -t -f UUID,TYPE connection | grep wireless | sed 's/:.*$//' | xargs nmcli con del "
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli d wifi connect ${WLAN_ID} password ${WLAN_PASS}"
	sleep 3
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
                sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "iperf3 -c ${HOST_IPERF} -t 5 -J | jq -r '.intervals' | grep bits_per_second | awk '{print \$2}' | awk '{printf(\"%.0f\n\", \$1)}' | awk '{\$1/=1000000;printf \"%.0f MBits/s\n\",\$1}' | sed -n 'p;n'"  | tee -a logs/${HOST}.log

	else
		display_alert "connecting to wireless" "${WLAN_ID}" "err"
	fi

}


function run_tests
{
display_alert "Try if we can login and send CTRL C" "$HOST" "info"
ssh-keygen -qf "/root/.ssh/known_hosts" -R "${HOST}" > /dev/null 2>&1
sshpass -p 1234 ssh -o "StrictHostKeyChecking=accept-new" ${USER_ROOT}@${HOST} "\x03" &>/dev/null
[[ $? -eq 1 ]] && armbian-first-login
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "apt -qq -y install jq stress" &>/dev/null
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "armbianmonitor -u" | tee -a logs/${HOST}.log
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
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "stress -q --cpu $(nproc) --io 4 --vm 2 --vm-bytes 128M --timeout ${STRESS_TIME}s"
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
}
