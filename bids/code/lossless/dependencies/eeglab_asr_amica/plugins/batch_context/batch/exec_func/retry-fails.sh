#!/bin/bash

set -eu

if [ $# -lt 1 ] ; then
    cat << HEAD
    Usage: $0 [wrapped_program] [otherargs...]
        Runs wrapped_program with otherargs a few times with a delay
        that allows the program to fail a few times but recover
HEAD
    exit 1
fi

wp="$1"
shift

function rand_float {
    echo "$RANDOM/32767.0" | bc -l
}

retrys=20
set +e
for i in `seq $retrys`; do
    "$wp" "$@"
    if [ $? -eq 0 ] ; then
        exit 0;
    fi
    echo "Failed to run $wp, try $i/$retrys, sleeping for random time"
    sleep `rand_float`
done
set -e
