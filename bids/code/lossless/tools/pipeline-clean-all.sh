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

set -u

if ! [ `which octave` ] ; then
    echo "No octave interpreter available, re run with octave in path"
    exit 1
fi

prog="`dirname $0`/pipeline-clean.sh"

ln=0

while IFS='' read -r line ; do
    # TODO(brad)
    [[ $line =~ -(.+T.{8}) ]]
    time[ln]=${BASH_REMATCH[1]}
    [[ $line =~ .*/(.*)_(.*).m ]]
    mname[ln]="${BASH_REMATCH[1]}_${BASH_REMATCH[2]}"
    pname[ln]="${BASH_REMATCH[1]}"
    ln=$(($ln+1))
done < <(find . -type f -wholename '*s16*/*.m')
end=$(($ln-1))
for i in `seq 0 $end` ; do
    "${prog}" ${pname[i]} ${mname[i]} ${time[i]} 
done