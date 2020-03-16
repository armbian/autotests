#!/bin/bash


function get_device() {
	local ips=()
	sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${USER_HOST} '
	for f in /sys/class/net/*; do
		intf=$(basename $f)
		# match only interface names starting with e (Ethernet), br (bridge), w (wireless), r (some Ralink drivers use ra<number> format)
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

} # get_ip_addresses




#--------------------------------------------------------------------------------------------------------------------------------
# Let's have unique way of displaying alerts
#--------------------------------------------------------------------------------------------------------------------------------
display_alert()
{
	local tmp=""
	[[ -n $2 ]] && tmp="[\e[0;33m $2 \x1B[0m]"

	case $3 in
		err)
		echo -e "[\e[0;31m error \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${USER_HOST}.log
		echo "$(date  +%R:%S) $1" >> ${SRC}/logs/${USER_HOST}.txt
		;;

		wrn)
		echo -e "[\e[0;35m warn \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${USER_HOST}.log
		echo "$(date  +%R:%S) $1" >> ${SRC}/logs/${USER_HOST}.txt
		;;

		ext)
		echo -e "[\e[0;32m o.k. \x1B[0m] \e[1;32m$1\x1B[0m $tmp" | tee -a ${SRC}/logs/${USER_HOST}.log
		echo "$(date  +%R:%S) $1" >> ${SRC}/logs/${USER_HOST}.txt
		;;

		info)
		echo -e "[\e[0;32m o.k. \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${USER_HOST}.log
		echo "$(date  +%R:%S) $1" >> ${SRC}/logs/${USER_HOST}.txt
		;;

		*)
		echo -e "[\e[0;32m .... \x1B[0m] $1 $tmp" | tee -a ${SRC}/logs/${USER_HOST}.log
		echo "$(date  +%R:%S) $1" >> ${SRC}/logs/${USER_HOST}.txt
		;;
	esac
}




function run_tests
{
r=1
i=1

SUM=0
START=$(date +%s)
while [ $r -le ${PASSES} ]
do
while ! ping -c1 $USER_HOST &>/dev/null; do display_alert "Ping $USER_HOST failed $i" "$(date  +%R:%S)" "info"; sleep 2; i=$(( $i + 1 )); [[ $i -gt 5 ]] && return 1;done ; START=$(date +%s); display_alert "Host ${USER_HOST} found" "Run $r out of ${PASSES}" "info";

	i=1
	nc -zvw3 $USER_HOST 22 &> /dev/null
	if [[ $? -ne 0 ]]; then
		display_alert "Can't connect. SSH on $USER_HOST is closed" "$(date  +%R:%S)" "wrn"
	else
		readarray -t array < <(find $SRC/tests -maxdepth 2 -type f -name '*.bash' | sort)
		HEADER_MD+="\n|$BOARD_NAME|"
		HEADER_HTML+="\n<tr><td>$r/${PASSES}</td><td><a href=${BOARD_URLS[$x]}>${BOARD_NAMES[$x]}</a> ${BOARD_VERSIONS[$x]} ${BOARD_DISTRIBUTION_CODENAMES[$x]}<br>${BOARD_KERNELS[$x]}</td>"
		for u in "${array[@]}"
		do
			unset TEST_OUTPUT
			DATA_ALIGN="center"
			. $u
			[[ $TEST_SKIP != "true" ]] && HEADER_MD+="$TEST_OUTPUT|" && HEADER_HTML+="<td align=$DATA_ALIGN>$TEST_OUTPUT</td>"
			unset TEST_SKIP
		done
		HEADER_HTML+="</tr>\n"
		#echo -e $HEADER_MD
		#echo -e $HEADER_HTML
	fi

	r=$(( $r + 1 ))

done
}
