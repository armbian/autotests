#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="memory"
TEST_ICON="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/memory.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ "$r" -le "${SBCBENCHPASS}" ]]; then
	display_alert "This will take some time ..." "Please wait!" "info"
	#SBCBENCH=$(remote_exec "cat bench")
	SBCBENCH=$(remote_exec "sbc-bench | tee bench" "-t")
		if [[ $? -eq 0 ]]; then
			MEMCPY=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSET=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMCPYbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSETbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			SBCBENCHURL=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "uploaded" | grep -Eo '(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]')
			GETTEMP=$(curl -s $SBCBENCHURL | sed -n -e '/System health while running 7-zip multi core benchmark/,/Throttling/ p' | awk '{print $NF}' | cut -d'C' -f1 | sed -e '1,3d' | head -n -2 | awk '{print $NF}' | awk '{ total += $1 } END { print total/NR }' | awk '{print int($1+0.5)}')
			TEST_OUTPUT="$MEMCPY - $MEMSET"
			[[ $MEMCPY != $MEMCPYbig || $MEMSET != $MEMSETbig && $MEMSET != "standard" ]] && TEST_OUTPUT+="<br>$MEMCPYbig - $MEMSETbig"
		else
			TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/error.png>"
		fi
else
	TEST_OUTPUT="<img width=20 src=https://raw.githubusercontent.com/armbian/autotests/master/icons/na.png>"
fi

#while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH")
display_alert "Tiny memory bench" "Copy: $MEMCPY - Set: $MEMSET MB/s" "info"
