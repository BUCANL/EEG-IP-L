% submit_line() - produces one line of scheduler dependent submit.sh output
%                 this part abstracts the common parts of each scheduler
%                 and passes it to the specific drivers to get the 
%                 scheduler dependent line
%
% Usage:
%   >>  outstr = submit_line(drive, tjob, data_filename_index, waitlist)
%
% Inputs:
%   driver              - the driver we are using, should be subtype of 
%                         ef_base_driver
%   tjob                - the current job, corresponds to a htb file
%   data_filename_index - the current job index, this corresponds to
%                         participants files
%   waitlist            
%    
% Outputs:
%   out      - scheduler independent format for the concrete scheduler
%              implementation
%
% See also:
%   pop_runhtb

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Mae Kennedy
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

function outstr = submit_line(drive, tjob, data_filename_index, waitlist)

histfname = tjob.batch_hfn;
datafname = tjob.batch_dfn{data_filename_index};
batch_dfp = tjob.batch_dfp;
batch_config = tjob.batch_config;

%% Generate job_name

job_name = batch_config.job_name;

% batch_dfn
job_name = key_strswap(job_name, 'batch_dfn', datafname);
% batch_hfn
job_name = key_strswap(job_name, 'batch_hfn', histfname);

%% mfile_name and backup as job_name for compat
mfile_name = batch_config.mfile_name;

mfile_name = mfile_name_gen(mfile_name, datafname, histfname, job_name);

% batch_dfn
mfile_name = key_strswap(mfile_name, 'batch_dfn', datafname);
% batch_hfn
mfile_name = key_strswap(mfile_name, 'batch_hfn', histfname);

if isempty(mfile_name)
    mfile_name = job_name;
end

exec_path = strrep(fullfile(tjob.context_config.log, tjob.m_path),'\','/');

%% Read jobinit
fid_jobinit = fopen(batch_config.job_init,'r');
if fid_jobinit ~= -1
    job_init = fread(fid_jobinit,'*char')';
    fclose(fid_jobinit);
else
    job_init = batch_config.job_init;
end

%% Verify we are dealing with .set files otherwise skip this section
[~, ~, ext] = fileparts(datafname);
if strcmp(ext, '.set')
    dimensions = ef_get_eegdims(batch_dfp, datafname);
    % These variables are eval'd so they will show up as a warning
    c = dimensions.channels; %#ok<NASGU> % channels
    s = dimensions.samples; %#ok<NASGU> % samples
end

%% Memory calculations
memory_type = [];
memory_alloc = [];
if ~isempty(batch_config.memory)
    memory_type  = lower(batch_config.memory(end));
    memory_alloc = eval(batch_config.memory(1:end-1));
end


%% Time limit calculations
time_span = [];
if ~isempty(batch_config.time_limit)
    time_var = lower(batch_config.time_limit(end));
    time_span = eval(batch_config.time_limit(1:end-1));
    % Make everything into seconds
    switch time_var
        case 's'
        case 'm'
            time_span = time_span * 60;
        case 'h'
            time_span = time_span * 3600;
        otherwise
            error('End of time_limit field needs to be one of {s, m, h}');
    end
end

%% Other options
mpi = false;
if ~isempty(batch_config.mpi)
    mpi = strcmp(batch_config.mpi, 'true');
end

num_proc = 1;
if ~isempty(batch_config.num_tasks)
    num_proc = str2double(batch_config.num_tasks);
end

num_thread_per_proc = 1;
if  ~isempty(batch_config.threads_per_task)
    num_thread_per_proc = str2double(batch_config.threads_per_task);
end

program = batch_config.software;

program_options = batch_config.program_options;

exec_str = tjob.exec_str{data_filename_index};

generic_opts = batch_config.submit_options;

is_octave = strcmp(program, 'octave') || strcmp(program, 'matlab');
%% Wrapper file for octave

% This gets the rel dir to the octave_exit_wrapper
[dir, ~, ~] = fileparts(which(mfilename()));
dir = cd(cd(fullfile(dir, '../')));
reldir = dir(length(cd)+2:end);
% Relative octave wrapper dir
wrappername = [reldir filesep 'octave_exit_wrapper.m'];

%%

% char
job_spec.name = job_name;
job_spec.output = [exec_path, '/', mfile_name , '.log'];
% number
job_spec.timeseconds = time_span;
job_spec.memory_alloc = memory_alloc;
% char
job_spec.memory_type = memory_type;
job_spec.job_init = job_init;
% bool
job_spec.mpi = mpi;
% number
job_spec.num_proc = num_proc;
job_spec.num_thread_per_proc = num_thread_per_proc;
% char
job_spec.program = program;
% cellstr
job_spec.program_options = program_options;
% char
job_spec.exec_str = exec_str;
% bool
job_spec.is_octave = is_octave;
% char, no .m
job_spec.mfile_name = [exec_path, '/', mfile_name , '.m'];
% cellstr
job_spec.waitlist = waitlist;
% char (if any)
job_spec.wrappers = wrappername;
% cellstr
job_spec.generic_opts = generic_opts;

outstr = format_scheduler(drive, job_spec);

end
