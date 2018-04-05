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
