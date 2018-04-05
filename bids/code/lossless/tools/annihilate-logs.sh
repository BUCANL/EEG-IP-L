#!/bin/bash

choice=$1
set -eu
numoptions=4

function isnum {
    re='^[0-9]+$'
    [[ "${1-x}" =~ $re ]] 
    echo $?
}
if ! [ "$choice" ] ; then
    cat << EOF
    [0] Delete files/dirs in analyis/logs
    [1] Delete files/dirs in analysis/data/2_preproc
    [2] Delete core dumps and other such files from ./
    [3] Do all above steps
EOF
    while [ `isnum ${choice-x}` -eq 1 ] || ! [ $choice -lt $numoptions ] ; do
        read -p "Select option: " choice
    done
fi

set[0]=0
set[1]=0
set[2]=0
set[3]=0

set[$choice]=1

if [ $choice -eq 3 ] ; then
    set[0]=1
    set[1]=1
    set[2]=1
fi

if [ ${set[0]} -eq 1 ] ; then
    true
fi
if [ ${set[1]} -eq 1 ] ; then
    true
fi
if [ ${set[2]} -eq 1 ] ; then
    true
fi
