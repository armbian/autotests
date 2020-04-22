#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="memory"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/memory.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ "$r" -le "${SBCBENCHPASS}" ]]; then
	display_alert "This will take some time ..." "Please wait!" "info"
	GETTEMP=$(remote_exec "rm -f screenlog.0; screen -dmSL gettemp armbianmonitor -m")
	#SBCBENCH=$(remote_exec "cat bench")
	SBCBENCH=$(remote_exec "sbc-bench" "-t" "45m")
		if [[ $? -eq 0 ]]; then
			MEMCPY=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSET=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMCPYbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSETbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			SBCBENCHURL=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "uploaded" | grep -Eo '(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]')
			GETTEMP=$(remote_exec "screen -XS gettemp quit")
			GETTEMP=$(remote_exec "cat screenlog.0")
			GETTEMP=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$GETTEMP") | grep : | cut -d'C' -f1 | awk '{print $NF}' | awk '{ total += $1 } END { print total/NR }' | cut -d'.' -f1)
			TEST_OUTPUT="$MEMCPY - $MEMSET"
			[[ $MEMCPY != $MEMCPYbig || $MEMSET != $MEMSETbig ]] && TEST_OUTPUT+="<br>$MEMCPYbig - $MEMSETbig"
		else
			TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/error.png>"
		fi
else
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"
fi

#while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH")
display_alert "Tiny memory bench" "Copy: $MEMCPY - Set: $MEMSET MB/s" "info"
