% format_scheduler() - returns a string that represents a line for a
%                      single input data file on the given scheduler
%
% Usage:
%   >>  out = format_scheduler(driver, job_spec)
%
% Inputs:
%   driver   - the driver we are using, should be subtype of ef_base_driver
%   job_spec - scheduler independent format specified in
%              @ef_base_driver/submit_line
%    
% Outputs:
%   out      - scheduler dependent format for the concrete scheduler
%              implementation
%
% See also:
%   @ef_base_driver/submit_line

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
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

function out = format_scheduler(~, job_spec)
    out = '';
    if ~isempty(job_spec.job_init)
        out = [out job_spec.job_init];
    end
    %The following line is not robust to varying folder structures...
    retry_fails = 'bids/code/lossless/dependencies/eeglab_asr_amica/plugins/batch_context/batch/exec_func/retry-fails.sh';
    out = sprintf('%s%s sbatch', out, retry_fails);
    if ~isempty(job_spec.name)
        out = sprintf('%s --job-name=%s', out, job_spec.name);
    end
    if ~isempty(job_spec.output)
        out = sprintf('%s --output=%s', out, job_spec.output);
    end
    if ~isempty(job_spec.waitlist)
        waitstring = cellfun(@(x) [x ','], job_spec.waitlist, ...
            'UniformOutput', false);
        waitstring = [waitstring{:}];
        waitstring = waitstring(1:end-1);
        out = sprintf('%s --dependency=afterok:%s', out, waitstring);
    end
    if ~isempty(job_spec.memory_alloc) && ~isempty(job_spec.memory_type)
        switch job_spec.memory_type
            case 'g'
                job_spec.memory_alloc = job_spec.memory_alloc * 1000;
                job_spec.memory_type = 'm';
            case 'm'
            otherwise
                error(['The ef_sbatch_driver only supports memory in ' ...
                    '''m'' or ''g''']);
        end
        out = sprintf('%s --mem-per-cpu=%d%s', out, ...
            fix(job_spec.memory_alloc), job_spec.memory_type);
    end
    if ~isempty(job_spec.timeseconds)
        time_span = fix(job_spec.timeseconds);
        hours = fix(time_span / 3600);
        time_span = mod(time_span, 3600);
        minutes = fix(time_span / 60);
        time_span = mod(time_span, 60);
        seconds = fix(time_span);
        time_str = sprintf('%02d:%02d:%02d', hours, minutes, seconds);
        out = sprintf('%s --time=%s', out, time_str);
    end
    if ~isempty(job_spec.num_proc) && job_spec.num_proc ~= 1
        out = sprintf('%s --ntasks=%d', out, job_spec.num_proc);
    end
    
    if ~isempty(job_spec.num_thread_per_proc) ...
            && job_spec.num_thread_per_proc ~= 1
        out = sprintf('%s --cpus-per-task=%d', out, ...
            job_spec.num_thread_per_proc);
    end
    
    % Add the generic options here
    generic_opts_str = cellfun(@(x) [x ' '], job_spec.generic_opts, ...
        'UniformOutput', false);
    generic_opts_str = [generic_opts_str{:}];
    generic_opts_str = generic_opts_str(1:end-1);
    if ~isempty(generic_opts_str)
        out = sprintf('%s %s', out, generic_opts_str);
    end
    
    runwith = '';
    if job_spec.mpi
        runwith = 'srun ';
    end

    wrapper = '';
    if job_spec.is_octave && ~isempty(job_spec.wrappers)
        wrapper = [' ' job_spec.wrappers];
    end
    
    poptions_string = cellfun(@(x) [x ' '], job_spec.program_options, ...
        'UniformOutput', false);
    poptions_string = [poptions_string{:}];
    
    if job_spec.is_octave
        out = sprintf('%s <(echo -e ''#!/bin/bash%s%s %s%s %s'')', ...
            out, '\n', job_spec.program, poptions_string, wrapper, job_spec.mfile_name);
    else
        out = sprintf('%s <(echo -e ''#!/bin/bash%s%s%s'')', ...
        	out, '\n', runwith, job_spec.exec_str);
    end
end
