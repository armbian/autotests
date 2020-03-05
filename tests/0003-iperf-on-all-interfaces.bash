#!/bin/bash

source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "pkill iperf3;iperf3 -Ds --pidfile /var/run/iperf3"
readarray -t array < <(get_device "^bond.*|^[ewr].*|^br.*|^lt.*|^umts.*" "ip")
for u in "${array[@]}"
do
	iperf3 -c ${u} -t 5 -J | jq -r '.intervals' | grep bits_per_second | awk '{print $2}' | \
		awk '{printf("%.0f\n", $1)}' | awk '{$1/=1000000;printf "%.0f MBits/s\n",$1}' | sed -n 'p;n' | \
		sed  "s/^/$u -> /" | tee -a ${SRC}/logs/${HOST}.log | tee -a ${SRC}/logs/${HOST}.txt
done
sleep 3
sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "pkill -F /var/run/iperf3"
