#!/bin/bash
#
# mask_ip
#
#




#
# Masking IP prefix address to make report copy/paste ready
#

function mask_ip(){

	echo $1 | cut -d . -f 3,4

}




#
# Remote execution wrapper
#
function remote_exec(){

	if [[ -z $3 ]]; then
		local TIMEOUT=60m
	else
		local TIMEOUT=$3
	fi

	f=0;
	while ! nc -zvw3 $USER_HOST 22 &>/dev/null
	do
		sleep 1; f=$(( $f + 1 )); [[ $f -gt 5 ]] && return 1
	done
	[[ $? -eq 0 ]] && timeout $TIMEOUT sshpass -p ${PASS_ROOT} ssh ${2} ${USER_ROOT}@${USER_HOST} "${1}" 2> /dev/null

}



#
# Get board data
#
function get_board_data(){
	local UptimeString=$(remote_exec "uptime")
	local UPT1=${UptimeString#*'up '}
	local UPT2=${UPT1%'user'*}
	local time=${UPT2%','*}

	BOARD_DATA=$(remote_exec "cat /etc/armbian-release")
	if [ "$BOARD_DATA" == "" ]; then
		echo "Remote host is not runnig Armbian. Exiting.."
		exit
	fi
	echo -e "$BOARD_DATA" >> ${SRC}/logs/${USER_HOST}.txt 2>&1

	BOARD_UPTIME=${time//','}
	root_uuid=$(remote_exec "sed -e 's/^.*root=//' -e 's/ .*$//' < /proc/cmdline")
	root_partition=$(remote_exec "blkid | tr -d '\":' | grep \"${root_uuid}\" | awk '{print \$1}'")
	root_partition_device="${root_partition::-2}"
	BOARD_UBOOT=$(remote_exec "dd status=none if=${root_partition_device} count=5000 | strings | grep armbian | grep U-Boot | tail -1 | cut -f1 -d\"(\"")
	BOARD_KERNEL=$(remote_exec "uname -sr")
	BOARD_BOARD=$(echo -e "$BOARD_DATA" | grep -w BOARD | sed 's/\"//g' | cut -d "=" -f2)
	BOARD_NAME=$(echo -e "$BOARD_DATA" | grep BOARD_NAME | sed 's/\"//g' | cut -d "=" -f2)
	BOARD_URL="https://www.armbian.com/"$(echo -e "$BOARD_DATA" | grep BOARD | head -1 | cut -d "=" -f2)
	BOARD_VERSION=$(echo -e "$BOARD_DATA" | grep VERSION | head -1 | cut -d "=" -f2)
	BOARD_DISTRIBUTION_CODENAME=$(echo -e "$BOARD_DATA" | grep DISTRIBUTION_CODENAME | head -1 | cut -d "=" -f2)
	BOARD_IMAGE_TYPE=$(echo -e "$BOARD_DATA" | grep IMAGE_TYPE | head -1 | cut -d "=" -f2)
	BOARD_LINUXFAMILY=$(echo -e "$BOARD_DATA" | grep LINUXFAMILY | head -1 | cut -d "=" -f2)
	#BOARD_BRANCH=$(echo -e "$BOARD_DATA" | grep BRANCH | head -1 | cut -d "=" -f2)
	BOARD_BRANCH=$(remote_exec "[[ -n $(cat /etc/apt/sources.list.d/armbian.list 2> /dev/null | grep apt) ]] && && echo 'stable' || echo 'nightly')")
}




#
# get_ip_addresses or interfaces
#
function get_device() {
	local ips=()
	remote_exec '
	for f in /sys/class/net/*; do
		intf=$(basename $f)
		# match only interface names starting with e (Ethernet), br (bridge) 
		# w (wireless), r (some Ralink drivers use ra<number> format)
		if [[ "$intf" =~ '$1' ]]; then
			tmp=$(ip -4 addr show dev $intf | grep inet | awk "{print \$2}" | cut -d"/" -f1)
			if [[ "'$2'" == ip ]]; then
				[[ -n $tmp ]] && echo $tmp
			elif [[ "'$2'" == noip ]]; then
				[[ -z "$tmp" && -n "$intf" ]] && echo $intf
			else
				echo $intf
			fi
		fi
	done'

}




#
# Let's have unique way of displaying alerts
#

display_alert()
{
	local tmp=""
	[[ -n $2 ]] && tmp="[\e[0;33m $2 \x1B[0m]"

	case $3 in
		err)
		echo -e "[\e[0;31m err. \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${REPORT}-$(mask_ip "$USER_HOST").log
		;;

		wrn)
		echo -e "[\e[0;35m warn \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${REPORT}-$(mask_ip "$USER_HOST").log
		;;

		ext)
		echo -e "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp" | tee -a ${SRC}/logs/${REPORT}-$(mask_ip "$USER_HOST").log
		;;

		info)
		echo -e "[\e[0;32m o.k. \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${REPORT}-$(mask_ip "$USER_HOST").log
		;;

		*)
		echo -e "[\e[0;32m .... \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${REPORT}-$(mask_ip "$USER_HOST").log
		;;
	esac
}


function wait_for_board
{

		# wait for a board for a while
		i=1
		while ! ping -c1 $USER_HOST &>/dev/null; do
			display_alert "Ping $USER_HOST failed $i" "$(date  +%R:%S)" "info"
			sleep 10
			i=$(( $i + 1 ))
			# give up after 50s
			if [[ $i -gt 5 ]]; then
				display_alert "Ping gave up" "$(date  +%R:%S)" "err"
				return 1
				break
			fi
		done

		display_alert "Host $(mask_ip "$USER_HOST") found" "Run $r out of ${PASSES}" "info";

		# wait for SSHD to come up
		f=1
		while ! nc -zvw3 $USER_HOST 22 &>/dev/null
		do
			sleep 10
			f=$(( $f + 1 ))
			[[ $f -gt 4 ]] && false && break
			display_alert "Probing SSH port on $USER_HOST" "$f $(date  +%R:%S)" "info"
		done

}



function run_tests
{
r=1
i=1
BODY_HTML=""
SUM=0
# run board test loop PASSES time
while [ $r -le ${PASSES} ]
	do

		# wait until you get ping and sshd response
		wait_for_board
		# show error that we can't connect to the hosts sshd
		if [[ $? -ne 0 ]]; then

			display_alert "Can't connect. SSH on $USER_HOST is closed" "$(date  +%R:%S)" "err"
			break

		else

			# otherwise proceed with running test cases
			# read tests
			readarray -t array < <(find $SRC/tests -maxdepth 2 -type f -name '*.bash' | sort)

			# read board information
			get_board_data

			# construct HTML for report
			BODY_HTML+="<tr>"$( [[ ${r} -eq 1 ]] && \
			echo "\n\t<td align=right rowspan=$((PASSES+1))>&nbsp;$((x+1))&nbsp;</td>\
			<td colspan=2>${BOARD_NAME} $(mask_ip "$USER_HOST") Uptime: ${BOARD_UPTIME}</td>\
			<td colspan=3 align=center>MBits/s</td>\
			<td colspan=2 align=center>MB/s</td>\
			<td colspan=2 align=center>16 byte</td>\
			<td align=center>°C</td>\
			<td align=center>Mhz</td>\
			<td colspan=$((COLOUMB-9))></td>\n\
			</tr>\n<tr>")"\
			\n\t<td align=center>$r/${PASSES}<br><small>$(date  +%R:%S)</small></td>\
			<td>${BOARD_VERSION} (${BOARD_DISTRIBUTION_CODENAME})<br>${BOARD_KERNEL} ${BOARD_IMAGE_TYPE}<br>${BOARD_UBOOT}</td>"

			# run tests
			for u in "${array[@]}"
			do
				unset TEST_OUTPUT
				DATA_ALIGN="center"
				. $u
				[[ $TEST_SKIP != "true" ]] && BODY_HTML+="\t<td align=$DATA_ALIGN>$TEST_OUTPUT</td>"
				unset TEST_SKIP
			done
			BODY_HTML+="</tr>\n"

	fi

	r=$(( $r + 1 ))

done
# write board report
echo -e $BODY_HTML > ${SRC}/logs/${x}-${BOARD_BOARD}-$(mask_ip "$USER_HOST").html
}
