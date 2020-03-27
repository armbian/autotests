#!/bin/bash
#
# Simple autotest script.
#



#
# Install host dependencies
#


apt install -y -qq jq expect sshpass nmap &>/dev/null


#
# Create working directories
#


mkdir -p userconfig logs reports


# create sample configuration if id does not exits


if [[ ! -f userconfig/configuration.sh ]]; then

	cp lib/configuration.sh userconfig/configuration.sh
	echo "Setup finished. Edit userconfig/configuration.sh and run ./go.sh again!"
	exit

fi

# start measuring executing time
START=$(date +%s)

# define absolute path
SRC="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# report file name
REPORT="$(date +%Y%m%d%H%M%S)"

# load user configuration
source userconfig/configuration.sh

# load libraries
source lib/functions.sh

# remove logs each time we ran the script. Need to be changed
rm -rf ${SRC}/logs/* ${SRC}/reports/data.out

# exclude IP addresses defined in EXCLUDE
[[ -n $EXCLUDE ]] && HOST_EXCLUDE="--exclude ${EXCLUDE}"

# include IP addresses defined in INCLUDE
[[ -n $INCLUDE ]] && IFS=', ' read -r -a includearray <<< "$INCLUDE"

if [[ -n $SUBNET ]]; then # scan subnet if SUBNET is defined
	readarray -t hostarray < <(nmap $HOST_EXCLUDE --open -sn ${SUBNET} 2> /dev/null \
	| grep "ssh\|Nmap scan report" | grep -v "gateway" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
elif [[ -n $HOSTS ]]; then # otherwise read comma delimited IP address from HOSTS
	IFS=', ' read -r -a hostarray <<< "$HOSTS"
else # otherwise stops with an error
	echo "\$HOST not defined. Exiting." && exit 1 
fi

# merge HOSTS/SUBNET with INCLUDE
hostarray=("${includearray[@]}" "${hostarray[@]}")

# html report header
HEADER_HTML="<html>\n<head><style type="text/css">
	.TFtable{
		width:100%; 
		border-collapse:collapse; 
	}
	.TFtable td{ 
		padding:10px; border:#e0e3e6 1px solid;
	}
	/* provide some minimal visual accomodation for IE8 and below */
	.TFtable tr{
		background: #b8d1f3;
	}
	/*  Define the background color for all the ODD background rows  */
	.TFtable tr:nth-child(odd){ 
		background: #f6f8fa;
	}
	/*  Define the background color for all the EVEN background rows  */
	.TFtable tr:nth-child(even){
		background: #ffffff;
	}
</style>\n</head>\n<body><table class=\"TFtable\" cellspacing=0 width=100% border=0>
<tr><td align=right rowspan=2><img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/hashtag.png></td><td align=center rowspan=2>Board<br>/<br>
Cycle</td><td rowspan=2>Version / distribution <br>Kernel / variant</td>\n"


# cycle test cases and make a header row
#
# when DRY_RUN is set we cycle over test to basic information about tests, but do not run them
#
DRY_RUN=true
readarray -t array < <(find $SRC/tests -maxdepth 2 -type f -name '*.bash' | sort)
COLOUMB=0
for u in "${array[@]}"
do

	unset TEST_SKIP
	. $u
	if [[ $TEST_SKIP != "true" ]]; then
		COLOUMB=$((COLOUMB+1))
		if [[ COLOUMB -gt 5 ]]; then
			row=2;
			else
			row=1;
		fi
		HEADER_HTML+="<td align=center rowspan=$row>$TEST_ICON<br><small>$TEST_TITLE</small></td>"
	fi

done
HEADER_HTML+="</tr><tr><td align=middle colspan=3>Iperf send/receive (MBits/s)</td>
<td align=middle colspan=2>IO read/write (MBits/s)</td></tr>\n"
unset DRY_RUN


# Read cached database from previous succesfull test run. Display / log error if this run is different.
# Some host might not returned after the test cycle
#
i=0
while IFS="\n" read -r line; do

	eval "declare -a a$i=($line)"
	i=$((i+1))

done < ${SRC}/reports/data.in


# Cycle hosts and see if they are alive, login/create username 
# and read /etc/armbian-release and compare with previous run

x=0
for USER_HOST in "${hostarray[@]}"; do

	readarray -t array < <(find $SRC/init -maxdepth 2 -type f -name '*.bash' | sort)
	for u in "${array[@]}"
	do
		. $u

		vara="a$x[0]"
		varb="a$x[1]"
		# creating data for next comparission
		echo '"'$USER_HOST'" "'$BOARD_NAME'"' >> ${SRC}/reports/data.out
		if [[ "${COMPARE}" == "yes" && $i -gt 1 && ("$USER_HOST" != "${!vara}" || "$BOARD_NAME" != "${!varb}") ]]; then
			[[ -n $BOARD_NAME ]] && x=$((x+1))
			display_alert "${x}. ${!varb} was expected on $(mask_ip "${!vara}")" "$(date  +%R:%S)" "err"
		fi

		# always switch to stable build from repository if not already there
		if [[ -n "$BOARD_IMAGE_TYPE" && "$BOARD_IMAGE_TYPE" != stable ]]; then

			display_alert "Switch to stable builds" "$(date  +%R:%S)" "wrn"
			remote_exec "apt update; apt -y -qq install armbian-config; \
			LANG=C armbian-config main=System selection=Stable; reboot" "-t" &>/dev/null

		fi
		x=$((x+1))
	done

done

# Cycle boards and run tests

x=0
for USER_HOST in "${hostarray[@]}"; do

	run_tests
	[[ $? -ne 0 ]] && display_alert "Host failed" "$(mask_ip "$USER_HOST")" "err"
	x=$((x+1))

done

# close HTML file
HEADER_HTML+="</table></body>\n</html>\n"
echo -e $HEADER_HTML >> ${SRC}/reports/${REPORT}.html

# make a diff between current and previous board list
DIFF=$(diff --suppress-common-lines ${SRC}/reports/data.in ${SRC}/reports/data.out | sed 1d)
[[ -z $DIFF ]] && cp ${SRC}/reports/data.out ${SRC}/reports/data.in

# Show script run duration
echo "This whole procedure took "$((($(date +%s) - $START)/60))" minutes".
