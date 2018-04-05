% ef_current_base() - Execute the batch pipeline defined by the current level 
% of the job_struct structure created by pop_runhtb in the current base workspace.
%
% Usage:
%  >> job_struct=ef_current_base(job_struct)
%
% Required Inputs:
%   job_struct  = structure created by pop_runhtb that contains the
%                 combined infomration required to execute a batch pipeline.
%
% Outputs:
%   job_struct  = updated intput.
%
% Notes:
%   This function is called to execute a batch pipeline in the current base
%   workspace when the batch_config.exec_func is set to ef_current_base.
%
% See also: pop_runhtb()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, and Andrew Lofts
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

function job_struct=ef_current_base(job_struct)

%% RUN EF_GEN_M...
job_struct(end)=ef_gen_m(job_struct(end));


%% EXECUTE M FILES IN THE CURRENT LOG PATH...
disp(['Begining to execute scripts in ', fullfile( ...
    job_struct(end).context_config.log, job_struct(end).m_path)])
addpath(fullfile(cd, job_struct(end).context_config.log, ...
    job_struct(end).m_path));
d = dir(fullfile(job_struct(end).context_config.log, ...
    job_struct(end).m_path,'/*.m'));

for i=1:length(d)
    disp(['Evaluating... ',d(i).name,' from ', ...
        job_struct(end).m_path,' directory...']);
    try
        [~,evalfname] = fileparts(d(i).name);
        diary(fullfile(cd, job_struct(end).context_config.log, ...
            job_struct(end).m_path, [evalfname, '.log']));
        addpath(fullfile(cd, ...
            job_struct(end).context_config.log, ...
            job_struct(end).m_path));
        
        evalin('base', 'evalworkspace = who;');
        evalin('base', evalfname);
        evalin('base', 'clearvars(''-except'', evalworkspace{:});');
        
        diary('off');
    catch err
        disp(sprintf('Script %s, in %s, failed', ...
            evalfname, job_struct(end).m_path))
        
        msg_fstack = logging_fcallstack([], [], [], err);
        builtin('disp', msg_fstack);
        fiderr = fopen(fullfile(cd, job_struct(end).context_config.log, ...
            job_struct(end).m_path, [evalfname, '.err']), 'w');
        fprintf(fiderr, msg_fstack);
        fclose(fiderr);
    end
end

rmpath(fullfile(cd, job_struct(end).context_config.log, ...
    job_struct(end).m_path));

end

%% From matlog
function output = logging_fcallstack(messagen, formatstr, unroll, lerror)
  global CALL_STACK_FORMAT;
  if ~exist('formatstr', 'var') || (exist('formatstr', 'var') ...
          && isempty(formatstr))
    formatstr = '\tat %s(%s:%d)\n';
  end
  if ~isempty(CALL_STACK_FORMAT)
    formatstr = CALL_STACK_FORMAT;
  end
  if ~exist('messagen', 'var') || isempty(messagen)
    messagen = 'Stack trace:\n';
  end
  if ~exist('unroll', 'var') || isempty(unroll)
    unroll = 1;
  end
  output = '';
  if ~exist('lerror', 'var')
    stack = dbstack();
  else
    stack = lerror.stack;
    output = sprintf('ERROR: %s\n', lerror.message);
    unroll = unroll - 1;
  end
  output = [output sprintf(messagen)];
  % CHECK: should this be < or <=
  if numel(stack) < unroll+1
    return;
  end
  
  stack = stack(unroll+1:end);

  for i = 1:numel(stack)
    level = stack(i);
    output = [output sprintf(formatstr, level.file, level.name, ...
      level.line)];
  end
end
 
