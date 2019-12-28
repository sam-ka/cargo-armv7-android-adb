#!/bin/sh
set -eu

[ -d "/crate" ] || {
    echo "ERROR: Mount crate directory at /crate" 1>&2
    exit 1
}

# Make sure that target is armv7-linux-androideabi
VALID_TARGET=""
for arg in "$@"; do 
    if [ $arg = "--target=armv7-linux-androideabi" ]; then
        VALID_TARGET="YES"
    fi
done

[ "$VALID_TARGET" = "YES" ] || {
    echo "ERROR: target must be armv7-linux-androideabi" 1>&2
    exit 1
}

#Make sure adb server is already running on default port 5037/tcp
nc -z localhost 5037 || {
    echo "ERROR: ADB is not running on host system or is listening on a port" 1>&2
    echo "that is not 5037. Run 'adb devices' before running this container " 1>&2
    echo "to both start the server and check that your device is correctly "  1>&2
    echo "detected." 1>&2
    exit 1
}

cd "/crate" && cargo "$@"
