% text2struct_bc() - Read a formated text file into the workspace as a
% batch_config structure.
%
%
% Usage:
%  >> batch_config=text2struct_bc(fname)
%
% Graphical Interface:
%
% Required Inputs:
%   fname         = Name of the formated text file to read.
%
% Optional Inputs:
%
% Outputs:
%    batch_config = Structure containing parameters for HIstory Template
%                   Batching file execution.
%
% See also: pop_loadbatchconfig, pop_batch_edit(), pop_runhtb()

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

function vised_config=text2struct_ve(fname)
% 
% vised_config.pop_gui='';
% vised_config.data_type='';
% vised_config.chans='';
% vised_config.event_type={''};
% vised_config.winrej_marks_labels={''};
% vised_config.quick_evtmk='';
% vised_config.quick_evtrm='';
% vised_config.quick_chanflag='';
% vised_config.chan_marks_struct='';
% vised_config.time_marks_struct='';
% vised_config.marks_y_loc=[];
% vised_config.inter_mark_int=[];
% vised_config.inter_tag_int=[];
% vised_config.marks_col_int=[];
% vised_config.marks_col_alpha=[];
% vised_config.srate=[];
% vised_config.spacing=[];
% vised_config.eloc_file='';
% vised_config.limits=[];
% vised_config.freqlimits=[];
% vised_config.winlength=[];
% vised_config.dispchans=[];
% vised_config.title='';
% vised_config.xgrid='';
% vised_config.ygrid='';
% vised_config.ploteventdur='';
% vised_config.data2='';
% vised_config.command='';
% vised_config.butlabel='';
% %vised_config.winrej='';
% vised_config.color='';
% vised_config.wincolor=[];
% %vised_config.colmodif={};
% %vised_config.tmp_events=[];
% vised_config.submean='';
% vised_config.position=[];
% vised_config.tag='';
% vised_config.children=[];
% vised_config.scale='';
% vised_config.mocap='';
% vised_config.selectcommand={''};
% vised_config.altselectcommand={''};
% vised_config.extselectcommand={''};
% vised_config.keyselectcommand={''};
% vised_config.mouse_data_front='';
% vised_config.trialstag=[];
% vised_config.datastd=[];
% vised_config.normed=[];
% vised_config.envelope=[];
% vised_config.chaninfo=[];
vised_config = init_vised_config;


keywords=fieldnames(vised_config);


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
        if ischar(eval(['vised_config.',keywords{field_ind}]));
            vised_config=setfield(vised_config,keywords{i},key_val{:});
        end
        if iscell(eval(['vised_config.',keywords{field_ind}]));
            vised_config=setfield(vised_config,keywords{i},key_val);
        end
        if isnumeric(eval(['vised_config.',keywords{field_ind}]));
            vised_config=setfield(vised_config,keywords{i},str2num(key_val{:}));
        end
    end
end
