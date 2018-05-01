#!/bin/bash

# Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
#
# Code written by Brad Kennedy
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

file=$1

jobidis=`grep -E "Jobid\ is\:\ [0-9]+" "${file}"`
needto=`grep -E "BradNET\ Epilogue" "${file}"`

if [ "${needto}" ] || ! [ "${jobidis}" ]; then
        echo -e "The file $file does not need an epilogue or has no jobid line \n" \
	     "Needed: $(! [ "${needto}" ] && echo true || echo false)\n" \
             "jobid: $([ "$jobidis" ] && echo true || echo false)" >&2
        exit 1
fi

set -eu

re='Jobid is: ([0-9]+)'
[[ "$jobidis" =~ $re ]]

id="${BASH_REMATCH[1]}"

# For some reason each job has two entries, the first contains the TimeLimit
# the second contains everything else... not sure what this is

timelimit=$(sacct -j "$id" --format=TimeLimit --parsable2 | tail -n 2 | head -n 1)

outline=$(sacct -j "$id" \
--format=MaxRSS,ElapsedRaw,ResvCPURAW,Submit,Start,NCPUS,ReqMem,TotalCPU,State \
--parsable2 | tail -n 1)

# Read the parameters from the good sacct of the completed job

IFS='|' read -r maxrss elapsed ign submit start ncpus reqmem totalcpu \
        completed <<< $outline

# This section covers hours:minutes:secs to seconds

IFS=':' read -r hours min sec <<< $timelimit
timelimit=$((10#$sec + 10#$min*60 + 10#$hours*3600))

# Keep the submit time formatted
submittime=$submit
IFS=':' read -r hours min sec <<< $submit
IFS='T' read -r ign hours <<< $hours
submit=$((10#$sec + 10#$min*60 + 10#$hours*3600))
IFS=':' read -r hours min sec <<< $start
IFS='T' read -r ign hours <<< $hours
start=$((10#$sec + 10#$min*60 + 10#$hours*3600))

# Store the queue time in seconds
qtime=$(($start-$submit))

# Get all the formatting options for sacct so we can print ALL OF THEM
allformat=`printf ",%s" $(sacct --helpformat)`
allformat=${allformat:1}

# This gets if the job is completed for exit status

iscompleted=1
if [[ $completed == "COMPLETED" ]] ; then
        iscompleted=0
fi



echo "Adding Epilogue to $file" >&2
cat >> $file << HEAD

--- BradNET csv ---
`sacct -j "$id" --format="$allformat" --parsable2 | tr '|' ','`

--- BradNET Epilogue ---
         job id: $id
    exit status: $iscompleted
       cpu time: $totalcpu
   elapsed time: ${elapsed}s / ${timelimit}s
resident memory: $maxrss / $reqmem
          ncpus: $ncpus
      queuetime: ${qtime}s
     submittime: $submittime
Job completed
HEAD

