% propgrid2batchconfig() - Translate the class def object for batch_config
% PropertyGrid GUI editing into a structure. 
%
%
% Usage:
%  >> batchconfig = propgrid2batchconfig(propgrid,batchconfig);
%
% Graphical Interface:
%
% Required Inputs:
%   propgrid      = class def object to be translated into batch_config
%                   structure.
%
%   batch_config  = batch_configuration structure created from
%                   pop_batch_edit. If empty a new one is created 
%                   via init_batch_config.
%
% Outputs:
%    batchconfig  = structure containing parameters for the batch
%                   execution of history template batch scripts.
%
% Notes: The batch_config structure is only translated into an object at
% the time of being displayed in the PropertyGrid GUI. Once that the GUI is
% closed it is translated back to a structure and is only handled as a
% structure by other functions and the workspace.
%
%
% See also: pop_runhtb(), pop_batch_edit(), init_batch_config()

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

function batchconfig = propgrid2batchconfig(propgrid,batchconfig)

npg=length(propgrid.Properties);
nlevels=npg/4;

if nargin==1;
    batchconfig=init_batch_config;
end

exec_properties = {
    'session_init', ...
    'job_name', ...
    'job_init', ...
    'mfile_name', ...
    'm_init', ...
    'submit_options', ...
    'memory', ...
    'time_limit', ...
    'mpi', ...
    'num_tasks', ...
    'threads_per_task', ...
    'software', ...
    'program_options' ...
};

for li=1:nlevels;
    % Some aliases
    propi = li - 1;
    pp = propgrid.Properties;
    ppexec_conf = propgrid.Properties(li*4);

    batchconfig(li).exec_func = strtrim(pp(propi*4+1).Value);
    batchconfig(li).replace_string = strtrim(pp(propi*4+2).Value);
    batchconfig(li).order = pp(propi*4+3).Value;

    for i = 1:length(exec_properties)
        batchconfig(li).(exec_properties{i}) = ...
            strtrim(ppexec_conf.Children(i).Value);
    end

end 
