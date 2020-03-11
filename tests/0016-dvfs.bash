#!/bin/bash
source $SRC/lib/functions.sh

display_alert "$(basename $BASH_SOURCE)" "${BOARD_NAMES[$x]} @ ${HOST}" "info"

min='[[ -d /sys/devices/system/cpu/cpu0/cpufreq ]] && echo -n $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq | head -1)/1000")" - " '
max='[[ -d /sys/devices/system/cpu/cpu0/cpufreq ]] && echo $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq | head -1)/1000")" Mhz" '

resoult=$(sshpass -p ${PASS_ROOT} ssh ${USER_ROOT}@${HOST} "eval $min; eval $max")
[[ -n $resoult ]] && display_alert "DVFS works" "$resoult" "info"
