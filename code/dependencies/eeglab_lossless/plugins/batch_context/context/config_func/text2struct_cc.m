% text2struct_cc() - Read a formated text file into the workspace as a
% context_config structure.
%
% Usage:
%  >> context_config=text2struct_cc(fname)
%
% Required Inputs:
%   fname            = Name of the formated text file to read.
%
% Outputs:
%    context_config  = Structure containing context parameters for History Template
%                      Batching file execution.
%
% See also: pop_context_edit(), pop_runhtb()

%Copyright (C) 2013 BUCANL
%
%Code originally written by Allan Campopiano with contributions from 
%James Desjardins and Andrew Lofts, supported by NSERC funding to 
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


function context_config=text2struct_cc(fname)

context_config.log='';
context_config.local_project='';
context_config.local_dependency='';
context_config.remote_user_name='';
context_config.remote_exec_host='';
context_config.remote_project_archive='';
context_config.remote_project_work='';
context_config.remote_dependency='';
context_config.mount_archive='';
context_config.mount_work='';
context_config.misc={''};
context_config.system_cmds={''};

keywords=fieldnames(context_config);


fileID = fopen(fname);
C = textscan(fileID,'%s', 'delimiter', '\n');
fclose(fileID);
cell_str={C{1}{:}}';


for i=1:length(keywords);
    try 
        key_ind(i)=find(strcmp(keywords{i},cell_str));
    catch
        key_ind(i)=0;
    end
end
key_ind_sort=sort(key_ind);
key_ind_sort(length(key_ind_sort)+1)=length(cell_str)+1;

for i=1:length(keywords);
    field_ind=i;
    if key_ind(field_ind)+1<=key_ind_sort(find(key_ind_sort==key_ind(field_ind))+1)-1;
        key_val=cell_str(key_ind(field_ind)+1:key_ind_sort(find(key_ind_sort==key_ind(field_ind))+1)-1);
        if ischar(eval(['context_config.',keywords{field_ind}]));
            context_config=setfield(context_config,keywords{i},key_val{:});
        end
        if iscell(eval(['context_config.',keywords{field_ind}]));
            context_config=setfield(context_config,keywords{i},key_val);
        end
        if isnumeric(eval(['context_config.',keywords{field_ind}]));
            context_config=setfield(context_config,keywords{i},str2num(key_val{:}));
        end
    end
end
    
