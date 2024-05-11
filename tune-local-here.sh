#!/bin/bash
set -eu
SELF="`realpath "$BASH_SOURCE"`"
SELF_DIR="`dirname "$SELF"`"
cd "$SELF_DIR"
CMD="$*"
if [[ -z "$CMD" ]]
then
    CMD=bash
fi
exec env -i XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR HOME=$SELF_DIR DISPLAY=$DISPLAY $CMD
#-noverifyfiles
