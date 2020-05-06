#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="DVFS"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/dvfs.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

min='[[ -d /sys/devices/system/cpu/cpu0/cpufreq ]] && echo -n $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq | head -1)/1000")" - " '
max='[[ -d /sys/devices/system/cpu/cpu0/cpufreq ]] && echo $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq | head -1)/1000") '
minbig='[[ -d /sys/devices/system/cpu/cpu4/cpufreq ]] && echo -n $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq | head -1)/1000")" - " '
maxbig='[[ -d /sys/devices/system/cpu/cpu4/cpufreq ]] && echo -n $(bc <<< "scale=0;$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq | head -1)/1000") '
resoult=$(remote_exec "eval $min; eval $max")
resoult_big=$(remote_exec "eval $minbig; eval $maxbig")
[[ -n $resoult_big ]] && resoult+="<br>"$resoult_big
[[ -n $resoult ]] && display_alert "... DVFS works" "$resoult Mhz" "info" && TEST_OUTPUT=$resoult
