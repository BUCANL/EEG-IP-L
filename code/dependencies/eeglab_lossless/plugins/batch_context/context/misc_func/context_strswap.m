% context_strswap() - replace context key strings (e.g. [remote_user_name])
% within a string array containing the appropriate variables taken from the
% context_config structure.
%
% Usage:
%  >> outstr=context_strswap(instr);
%
% Required Inputs:
%   instr       = A string array containing context key string. Accepted
%   context key strings are the filed names from context_config surrounded
%   by brackets "[]". The complete list of context key strings is:
%       [cd]
%       [local_project]
%       [local_dependency]
%       [log]
%       [remote_user_name]
%       [remote_exec_host]
%       [remote_project_archive]
%       [remote_project_work]
%       [remote_dependency]
%       [mount_archive]
%       [mount_work]
%   Other key strings can be added via the misc field of context_config in
%   which key val pairs can be added as a cell array of strings (e.g.
%   {'[key1] val1';'[key2] val2'}).
%
% Outputs:
%    outstr     = Instring with all instances of key strings swapped based
%                 on context_config fields.
%
% Typical use: This function is used to convert the system commands
% (system_cmds field) into executable commands called by the "system"
% button in the pop_context_edit GUI.
%
% See also: pop_context_edit()

%Copyright (C) 2013 BUCANL
%
%Code originally written by James A. Desjardins with contributions from 
%Allan Campopiano and Andrew Lofts, supported by NSERC funding to 
%Sidney J. Segalowitz at the Jack and Nora Walker Canadian Centre for 
%Lifespan Development Research (Brock University), and a Dedicated Programming 
%award from SHARCNet, Compute Ontario.
%
%This program is free software; you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation; either version 2 of the License, or
%(at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program (LICENSE.txt file in the root directory); if not, 
%write to the Free Software Foundation, Inc., 59 Temple Place,
%Suite 330, Boston, MA  02111-1307  USA



function outstr=context_strswap(instr)

try parameters = evalin('base', 'context_config');
    context_config=parameters;
catch %if nonexistent in workspace
    context_config=init_context_config;
end

outstr=instr;

outstr=strrep(outstr,'[cd]',cd);
if isempty(context_config.local_project)
    disp('local_project property is empty defaulting to cd');
    local_project=cd;
else
    local_project=context_config.local_project;
end
outstr=strrep(outstr,'[local_project]',local_project);
outstr=strrep(outstr,'[local_dependency]',context_config.local_dependency);

outstr=strrep(outstr,'[log]',context_config.log);

outstr=strrep(outstr,'[remote_user_name]',context_config.remote_user_name);
outstr=strrep(outstr,'[remote_exec_host]',context_config.remote_exec_host);
outstr=strrep(outstr,'[remote_project_archive]',context_config.remote_project_archive);
outstr=strrep(outstr,'[remote_project_work]',context_config.remote_project_work);
outstr=strrep(outstr,'[remote_dependency]',context_config.remote_dependency);

outstr=strrep(outstr,'[mount_archive]',context_config.mount_archive);
outstr=strrep(outstr,'[mount_work]',context_config.mount_work);

for i=1:length(context_config.misc);
   if ~isempty(context_config.misc{i});
       cs=strfind(context_config.misc{i},',');
       if ~isempty(cs);
           str1=strtrim(context_config.misc{i}(1:cs(1)-1));
           if strcmp(str1([1,end]),'[]');
               outstr=strrep(outstr,str1,strtrim(context_config.misc{i}(cs(1)+1:end)));
           end
       end
   end
end
