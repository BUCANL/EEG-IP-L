% init_context_config() - Creates a context_config classdef object containing the 
% properties that hold context parameters for batch executing history template 
% batching scripts. 
%
% Notes: The context_config structure is only translated into an object at
% the time of being displayed in the PropertyGrid GUI. Once that the GUI is
% closed it is translated back to a structure and is only handled as a
% structure by other functions and the workspace.
%
% See also: pop_runhtb(), pop_context_edit(), propgrid2contextconfig()

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

function context_config=init_context_config

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

