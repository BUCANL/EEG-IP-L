#!/bin/bash

# Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
#
# Code written by Mae Kennedy
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (LICENSE.txt file in the root directory); if not, 
# write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307  USA
set -eu

# Options
octavepath="analysis/support/dependencies/eeglab_asr_amica/plugins/other_functions"
matlogpath="analysis/support/dependencies/matlog"

if ! [ `which octave` ] ; then
    echo "No octave interpreter available, re run with octave in path"
    exit 1
fi

if [ $# -lt 3 ] ; then
    cat << HELP
Usage: $0 [datafile] [mfilename] [logs_dir] [varargs...]

datafile is the filename without extention or ending _
e.g. 'Babysib_654'
mfilename is the filename as described in batch_context mfilename
e.g. 'babysib_601_init'
logs_dir is an expression that matches the logs directory in
analysis/log
e.g. 2017-07-18T15-46-42
HELP
exit 1
fi

args=("$@")
# Change things to matlab representation
for i in `seq 0 $(($#-1))` ; do
    re1='^[0-9]+$'
    re2='(true|false)'
    if ! [[ ${args[i]} =~ $re1 ]] && ! [[ ${args[i]} =~ $re2 ]]; then
        args[i]="'${args[i]}'"
    fi
done

# Shift and add empty options
for i in `seq $# -1 4` ; do
    args[i]=${args[i-1]}
done

args[3]="[]"

# Add commas
cli=`printf ", %s" "${args[@]}"`
# Substring
cli=${cli:2}

octave << ENDALL

addpath('${octavepath}')
addpath('${matlogpath}')
pipeline_clean (${cli})
ENDALL