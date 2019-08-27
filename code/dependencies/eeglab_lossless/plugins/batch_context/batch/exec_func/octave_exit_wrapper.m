% exit_wrapper() - function that wraps any script providing exit statuses
%                  to any failing Matlab/Octave script that doesn't receive
%                  a fatal signal.
%                  Note: We are not aware of how this functions with scripts
%                        with command line options themselves
%
% Usage:
%   >>  octave exit_wrapper script-name
%
% Inputs:
%   script-name - the script to watchdog

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

arg_list = argv();
fname = arg_list{1};
arg_list = arg_list(2:end);

%% System specific jobid printing
% This is for internal benchmarking
jobid = getenv('SLURM_JOBID');
if ~isempty(jobid)
    disp(['Jobid is: ' jobid]);
end
jobid = getenv('SQ_JOBID');
if ~isempty(jobid)
    disp(['Jobid is: ' jobid]);
end

%% Run the wrapped script

[pathstr, name, ext] = fileparts(fname);
fullpath = fullfile(pathstr, [name, ext]);

% Check if the directory/file exists
if exist(pathstr, 'dir') ~= 7
    fprintf(['The specified file does not exist; The specified path' ...
        ' does not exist: %s'], pathstr);
    exit(1);
end

if ~exist(fullpath, 'file')
    fprintf('The specified file does not exist: %s\n', fullpath);
    exit(1);
end


addpath([pwd, '/', pathstr]);
try
    % We need a function handle
    eval(['fhandle = @', name, ';']);
    feval(fhandle, arg_list{:});
catch err
    try
        builtin('disp', ['Error: ' err.message]);
        output = '';
        stack = err.stack;
        for i = 1:numel(stack)
            level = stack(i);
            output = [output sprintf('\tat %s(%s:%d)\n', level.file, ...
                      level.name, level.line)];
        end
        builtin('disp', ['Stack trace:', char(10), output]);
    catch err
        builtin('disp', ['Stack trace not available, error was ' err.message]);
    end
    exit(1);
end

