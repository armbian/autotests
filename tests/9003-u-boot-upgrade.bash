#!/bin/bash
source $SRC/lib/functions.sh

TEST_TITLE="Update"
TEST_SKIP="true"
[[ $DRY_RUN == true ]] && return 0

display_alert "$(basename $BASH_SOURCE)" "$(date  +%R:%S)" "info"

root_uuid=$(remote_exec "sed -e 's/^.*root=//' -e 's/ .*$//' < /proc/cmdline")
root_partition=$(remote_exec "blkid | tr -d '\":' | grep \"${root_uuid}\" | awk '{print \$1}'")
root_partition_device="${root_partition::-2}"
remote_exec "[[ -f /usr/lib/u-boot/platform_install.sh ]] && source /usr/lib/u-boot/platform_install.sh && write_uboot_platform \$DIR ${root_partition_device}" "-t"
display_alert "Write u-boot to $root_partition_device with $root_uuid" "$(date  +%R:%S)" "info"
