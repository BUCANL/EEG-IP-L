% rsub_sys() - Submits the batch pipeline defined by job_struct structure 
% created by pop_runhtb to the SHARCNET scheduler via system calls (given
% that this is being called by a Unix based OS [Linux or Mac]).
%
% Usage:
%  >> job_struct=rsub_sys(job_struct, driver, password)
%
% Required Inputs:
%   job_struct = structure created by pop_runhtb that contains the
%                combined information required to submit a batch pipeline 
%                to the SHARCNET scheduler.
%   driver     = scheduler driver
%   sshfm_opts = password for sshfm if used, and other opts
%
% Outputs:
%   job_struct  = updated intput.
%
% Notes:
%   This function is called to submit a batch pipeline to the SHARCNET
%   scheduler when the batch_config.exec_func is set to ef_sqsub and the
%   "Remote submit communication method" is set to "system".
%
% See also: pop_runhtb()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts, and
% Brad Kennedy
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

function job_struct=rsub_sys(job_struct, driver, sshfm_opts)

issshfm = nargin > 2 && ~isempty(sshfm_opts);
tjob = job_struct(end);
cc = tjob.context_config;

%% SFTP FROM MATLAB M FILES TO THE REMOTE LOG...
zip([fullfile(cc.log, tjob.m_path),'.zip'], ...
    '*.*', ...
    fullfile(cc.log, tjob.m_path));

tjob.remote_log = fullfile(tjob.remote_work, ...
    cc.log);

% adjust path delimiters if necessary...
tjob.remote_log = strrep(tjob.remote_log, '\', '/');
% Copy back to our alias
job_struct(end).remote_log = tjob.remote_log;

%% SECURE COPY M FILE TO REMOTE HOST...
ziplocal = fullfile(cd, cc.log, [tjob.m_path,'.zip']);
if ~issshfm
    cmdstr = sprintf('scp %s %s@%s:%s', ...
        ziplocal, ...
        cc.remote_user_name, ...
        cc.remote_exec_host, ...
        tjob.remote_log);
    system_cmd_or_error(cmdstr, 'Failed to copy to remote');
else
    ssh2_conn = ssh2_config(cc.remote_exec_host, cc.remote_user_name, ...
        sshfm_opts.password);
    [localpath, localname, localext ] = fileparts(ziplocal);
    ssh2_conn = scp_put(ssh2_conn, [localname localext], ...
        tjob.remote_log, localpath);
end


%% GET THE QSUBSTR... UPDATE TO EXECUTION OF BASH SCRIPT...
% TODO(brad) fix these so they are readable
long_mpath = fullfile(cc.log, tjob.m_path);

sshhost = sprintf('%s@%s', cc.remote_user_name, cc.remote_exec_host);

cmd_str = ['cd %s && unzip %s.zip -d %s' ...
    ' && rm %s.zip && chmod +x %s/submit.sh && %s/submit.sh'];
cmd_str = sprintf(cmd_str, ... 
    tjob.remote_work, ...
    long_mpath, long_mpath, ...
    long_mpath, ...
    long_mpath, ...
    long_mpath);
if ~issshfm
    sys_str = sprintf('ssh %s ''%s''', sshhost, cmd_str);
    result_str = system_cmd_or_error(sys_str, 'Failed to submit script');
else
    ssh2_conn = ssh2_command(ssh2_conn, cmd_str);
    result_str = ssh2_conn.command_result;
    % result_str is cell array, we must change it to one string
    result_str = sprintf('%s\n', result_str{:});
    % remove last newline
    result_str = result_str(1:end-1);
    ssh2_close(ssh2_conn);
end

%% COLLECT THE NEW JOBIDS FROM THE SCHEDULER...

% New method uses read_jobs from driver to read in the jobids as a cellstr
job_struct(end).jobids = read_jobs(driver, result_str);
end

function result_str = system_cmd_or_error(cmd, msg)
    [exit_status, result_str] = system(cmd, '-echo');
    if exit_status ~= 0
        error('System error: %s\n\tCommand was: %s', msg, cmd);
    end
end

