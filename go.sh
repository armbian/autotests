#!/bin/bash
#
# Simple autotest script.
#

apt install -y -qq jq expect sshpass nmap &>/dev/null
mkdir -p userconfig logs

# create sample configuration
if [[ ! -f userconfig/configuration.sh ]]; then
	cp lib/configuration.sh userconfig/configuration.sh
	echo "Setup finished. Edit userconfig/configuration.sh and run ./go.sh again!"
        exit
fi

SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source userconfig/configuration.sh
source lib/functions.sh

# remove logs
rm -rf logs/*

[[ -n $EXCLUDE ]] && HOST_EXCLUDE="--exclude ${EXCLUDE}"
[[ -n $INCLUDE ]] && IFS=', ' read -r -a includearray <<< "$INCLUDE"

if [[ -n $SUBNET ]]; then
	readarray -t hostarray < <(nmap $HOST_EXCLUDE --open -sn ${SUBNET} | grep "ssh\|Nmap scan report" | grep -v "gateway" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
elif [[ -n $HOSTS ]]; then
	IFS=', ' read -r -a hostarray <<< "$HOSTS"
else
	echo "\$HOST not defined. Exiting." && exit 1
fi

hostarray=("${includearray[@]}" "${hostarray[@]}")

DRY_RUN=true
HEADER_HTML="<html>
<head>
<style>
td, tr {
    border: 1px solid black;
	padding: 8px;
}
table {
    border-collapse: collapse;
}
</style>
</head>
<body><table cellspacing=0 width=100% border=1><tr><td rowspan=2>Cycle</td><td rowspan=2>Board</td>\n"
HEADER_MD="|Board|"
readarray -t array < <(find $SRC/tests -maxdepth 2 -type f -name '*.bash' | sort)
COLOUMB=0
for u in "${array[@]}"
do
	unset TEST_SKIP
	. $u
	[[ $TEST_SKIP != "true" ]] && HEADER_MD+=$TEST_TITLE" |" && COLOUMB=$((COLOUMB+1)) && if [[ COLOUMB -gt 5 ]]; then row=2; else row=1; fi && HEADER_HTML+="<td align=center rowspan=$row>$TEST_ICON<br><small>$TEST_TITLE</small></td>"
done

HEADER_MD+="\n|:-|"

for u in "${array[@]}"
do
	unset TEST_SKIP
	. $u
	[[ $TEST_SKIP != "true" ]] && HEADER_MD+=":-|"
done

HEADER_HTML+="</tr><tr><td align=middle colspan=3>Iperf (MBits/s)</td><td align=middle colspan=2>IO (MBits/s)</td></tr>\n"

unset DRY_RUN

x=1
BOARD_NAMES=()
BOARD_KERNELS=()
BOARD_URLS=()
BOARD_VERSIONS=()
BOARD_DISTRIBUTION_CODENAMES=()
for USER_HOST in "${hostarray[@]}"; do
	readarray -t array < <(find $SRC/init -maxdepth 2 -type f -name '*.bash' | sort)
	for u in "${array[@]}"
	do
		. $u
		BOARD_NAMES+=("$BOARD_NAME")
		BOARD_KERNELS+=("$BOARD_KERNEL")
		BOARD_URLS+=("$BOARD_URL")
		BOARD_VERSIONS+=("$BOARD_VERSION")
		BOARD_DISTRIBUTION_CODENAMES+=("$BOARD_DISTRIBUTION_CODENAME")
#		BOARD_PIDS+=("$!");
		x=$((x+1))
	done
done

#sleep 15
#w=0
#for BOARD_PID in "${BOARD_PIDS[@]}"; do
#	kill $BOARD_PID 2> /dev/null
#	echo $?
#	w=$((w+1))
#done


x=0
for USER_HOST in "${hostarray[@]}"; do
	rm -f logs/${HOST}.log
	run_tests
	[[ $? -ne 0 ]] && display_alert "Host failed" "$USER_HOST" "err"
	x=$((x+1))
done

HEADER_HTML+="</table></body>
</html>\n"
echo -e $HEADER_HTML >> ${SRC}/logs/report.html
