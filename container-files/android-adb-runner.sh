#!/bin/sh
#
# Copyright (C) 2020 Kutometa SPLC, Kuwait
# License: LGPLv3 
# www.ka.com.kw
#
# This script tranfers a binary to an android device and runs it.
# This script is not related to Rust or cargo in any way.
#
# Even though file is ran in the container, the adb server it 
# connects to runs on the host.

[ "$1" ] || { 
    echo "Error: No run target supplied. Aborting."; 
    exit 1; 
}
set -eu
adb push "$1" "/data/local/tmp/android-runner-payload" >/dev/null 2>&1 || { 
    echo "Error: Could not copy '$1' to android device. Aborting."; 
    exit 1; 
}
shift
adb shell "/data/local/tmp/android-runner-payload" "$@"

