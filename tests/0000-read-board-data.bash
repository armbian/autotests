#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE=""
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

get_board_data

display_alert "$BOARD_NAME" "$BOARD_KERNEL" "info"
