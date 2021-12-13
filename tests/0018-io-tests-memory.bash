#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="memory"
TEST_ICON="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/memory.png>"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

if [[ "$r" -le "${SBCBENCHPASS}" ]]; then
	#SBCBENCH=$(remote_exec "cat bench")
	if [[ $EMULATED == yes ]]; then
		display_alert "Emulation mode ..." "Using fake data for sbc-bench" "info"
		SBCBENCH=$(cat $SRC/lib/sbc-bench.example)
	else
		display_alert "This will take some time ..." "Please wait!" "info"
		SBCBENCH=$(remote_exec "sbc-bench | tee bench" "-t")
	fi
		if [[ $? -eq 0 ]]; then
			MEMCPY=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSET=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | head -1 | cut -d' ' -f2,2 | cut -d'.' -f1)

			MEMCPYbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memcpy | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)
			MEMSETbig=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep memset | tail -1 | cut -d' ' -f2,2 | cut -d'.' -f1)

			AES128=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "aes-128" | head -1 | cut -d' ' -f2- | awk '{print $1}' | cut -d'.' -f1)
			AES256=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "aes-256" | head -1 | cut -d' ' -f2- | awk '{print $1}' | cut -d'.' -f1)

			SBCBENCHURL=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "uploaded" | grep -Eo '(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]')
			GETTEMP=$(curl -s $SBCBENCHURL | sed -n -e '/System health while running 7-zip multi core benchmark/,/###/ p' | awk '{print $NF}'| head -12 | cut -d'C' -f1 | sed -e '1,3d' | head -n -2 | awk '{print $NF}' | awk '{ total += $1 } END { print total/NR }' | awk '{print int($1+0.5)}')
			SEVENZIP=$(while IFS= read -r line; do    echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "7-zip total" | awk '{print $NF}' | sed "s/,/\n/g" | awk '{ total += $1 } END { print total/NR }' | cut -d'.' -f1)
			
			THROTTLING=$(while IFS= read -r line; do echo "$line"; done < <(printf '%s\n' "$SBCBENCH") | grep "ATTENTION: Throttling")
			
			TEST_OUTPUT="$MEMCPY - $MEMSET"
			[[ $MEMCPY != $MEMCPYbig || $MEMSET != $MEMSETbig && $MEMSET != "standard" ]] && TEST_OUTPUT+="<br>$MEMCPYbig - $MEMSETbig"
			display_alert "Tiny memory bench" "Copy: $MEMCPY - Set: $MEMSET MB/s" "info"
		else
			display_alert "SBC bench not finished in time" "" "err"
			TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/error.png>"
			MEMCPY=$TEST_OUTPUT
			MEMSET=$TEST_OUTPUT
			unset GETTEMP THROTTLING AES128 AES256 SBCBENCHURL
			display_alert "Tiny memory bench" "No data" "wrn"
		fi
else
	TEST_OUTPUT="<img width=20 src=${GITHUB_SOURCE}armbian/autotests/raw/master/icons/na.png>"
fi


