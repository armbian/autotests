#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$BOARD_NAME @ $(date  +%R:%S)" "info"

sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "pkill iperf3;iperf3 -Ds --pidfile /var/run/iperf3"

readarray -t array < <(get_device "^bond.*|^[ewr].*|^br.*|^lt.*|^umts.*" "ip")
for u in "${array[@]}"
do

	device=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "nmcli | awk -vRS='connected' '/$u/{print}' | head -3 | tail -2  | sed 'N;s/\n/ /' | tr -d '\011' | sed 's/..:..:..:..:..:.., //' ")
	speed_to=$(echo "$(iperf3 -c ${u} -t 10 -J | jq -r '.intervals' | grep bits_per_second | awk '{print $2}' | awk '{printf("%.0f\n", $1)}' | paste -sd+ | bc) / 20" | bc | awk '{$1/=1000000;printf "%.0f MBits/s\n",$1}')
	if [[ $device == *ethernet* ]]; then
		speed_from="~"$(echo "$(iperf3 -R -c ${u} -t 10 -J | jq -r '.intervals' | grep bits_per_second | awk '{print $2}' | awk '{printf("%.0f\n", $1)}' | paste -sd+ | bc) / 20" | bc | awk '{$1/=1000000;printf "%.0f MBits/s\n",$1}')
		else
		unset speed_from
	fi
	display_alert "...$device" "$speed_from ~$speed_to" "info"

done
sleep 3
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "pkill -F /var/run/iperf3"
