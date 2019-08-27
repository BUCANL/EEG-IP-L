% make_job_dir() - Helper function for creating the required state of a job folder.
%
% Usage:
%   >>  make_job_dir(driver,job_struct);
%
% Inputs:
%   drive - Reference to object which specifies cluster configurations.
%   job   - Specific submission information. See job_struct usage in pop_runhtb.
%
% Outputs:
%   An updated job_struct object with pathing information on each subject.
%
% See also:
%   pop_runhtb()
%

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts,
%                 and Mae Kennedy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program (LICENSE.txt file in the root directory); if not, 
% write to the Free Software Foundation, Inc., 59 Temple Place,
% Suite 330, Boston, MA  02111-1307  USA

function job = make_job_dir(drive, job)

if nargin < 2
    help @ef_base_driver/make_job_dir
    return;
end

% We use this a lot so lets make a shorter name
% this job
% Note: We have to restore this at the end due to copy semantics
tjob = job(end);

%% Generate m file for Octave/Matlab or exec function for programs

switch tjob.batch_config.software
    case 'octave'
        tjob = ef_gen_m(tjob);
    case 'matlab'
        tjob = ef_gen_m(tjob);
    otherwise
        tjob = ef_exec_str(tjob);
end

%% Collect the remote project work
i = strfind(tjob.context_config.remote_project_work, ':');
job(end).remote_work = tjob.context_config.remote_project_work(i(1) + 1:end);
tjob.remote_work = job(end).remote_work;

cmdstr = sprintf('#!/bin/bash\nset -e\n');

%% Read the sesinit
fid_sesinit = fopen(tjob.batch_config.session_init, 'r');
if fid_sesinit
    tmpstr = fread(fid_sesinit,'*char');
    fclose(fid_sesinit);
else
    tmpstr = tjob.batch_config.session_init;
end

cmdstr = sprintf('%s%s', cmdstr, tmpstr);

%% Loop through participants
for bfni = 1:length(tjob.batch_dfn)
    % Cycle through all the subject files

    waitlist = {};
    for l = 1:length(job)
        if any(job(l).ordernum == tjob.waitnum)
            % Add elements to the wait list cell array
            waitlist{end+1} = job(l).jobids{bfni};
        end
    end
    % Append it to the file string 
    tmpstr = submit_line(drive, tjob, bfni, waitlist);
    cmdstr = sprintf('%s\n%s', cmdstr, tmpstr);
end


%% WRITE [SUBSTRINIT,QSUBSTR] TO A *.SUB TEXT FILE IN THE LOG PATH...
fid = fopen(fullfile(tjob.context_config.log, tjob.m_path, 'submit.sh'), 'w');
fwrite(fid, cmdstr);
fclose(fid);

%% Write it back
job(end) = tjob;
