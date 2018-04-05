% propgrid2contextconfig() - Translate the class def object for context_config
% PropertyGrid GUI editing into a structure. 
%
% Usage:
%  >> contextconfig = propgrid2contextconfig(propgrid);
%
% Required Inputs:
%   propgrid      = class def object to be translated into context_config
%                   structure.
%
% Outputs:
%    contextconfig    = structure containing context parameters for the batch
%                       execution of history template batch scripts.
%
% Notes: The context_config structure is only translated into an object at
% the time of being displayed in the PropertyGrid GUI. Once that the GUI is
% closed it is translated back to a structure and is only handled as a
% structure by other functions and the workspace.
%
% See also: pop_runhtb(), pop_context_edit(), init_context_config()

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


function contextconfig = propgrid2contextconfig(propgrid)

npg=length(propgrid.Properties);

contextconfig=[];
for pi=1:npg;
    eval(['contextconfig.',propgrid.Properties(pi).Name,'=propgrid.Properties(pi).Value;']);
end
