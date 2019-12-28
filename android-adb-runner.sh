#!/bin/sh
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
