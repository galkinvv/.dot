#!/bin/sh
SELF=`readlink -f "$0"`
SELF_DIR=`dirname "$SELF"`
cd "$SELF_DIR"
trap 'echo signal ignored' INT STOP
unbuffer $SELF_DIR/run-daemon.sh | tee /dev/stderr | grep --line-buffered "daemon message" | while read line ; do sudo env -u SUDO_GID -u SUDO_COMMAND -u SUDO_USER -u SUDO_UID beep -l 300 -n -f 880 -n -f 1760; done
while true; do (bash -l); echo "Shell exited, started again"; done
