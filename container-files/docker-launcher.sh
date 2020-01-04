#!/bin/sh
#
# Copyright (C) 2020 Kutometa SPLC, Kuwait
# License: LGPLv3 
# www.ka.com.kw
#
# This file is responsible for making sure the cargo's environment 
# is correctly set up before running container args.
#
# This script is ran inside the container
#
# Curently it checks that 
#   * '/crate' is mounted
#   * Host ADB is reachable
#   * cargo's cwd is '/crate'
#   * add proper target flag
#

set -eu

[ -d "/crate" ] || {
    echo "ERROR: Mount crate directory at /crate" 1>&2
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

cargocmd="$1"
shift
cd "/crate" && cargo "$cargocmd" "--target=armv7-linux-androideabi" "$@"

