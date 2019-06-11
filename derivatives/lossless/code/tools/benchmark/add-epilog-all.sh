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

# This file uses add-epilog.sh to add an epilog to all files with
# a "Jobid is: [0-9]+" line in them, somewhat duplicating the
# experience on Sharcnet clusters with sqsub

set -eu

script="analysis/support/tools/add-epilog.sh"
maxjobs="8"

# Verify our environment

if ! [ `which sacct` ] ; then
	echo "We need sacct, is this a slurm system?" >&2
	exit 1
fi

while IFS='' read -r line; do
	"${script}" "$line" || true &
	if [ `jobs | wc -l` -gt $maxjobs ] ; then
		wait
	fi
done < <(find analysis/log -type f -name '*.log')
wait

