% init_batch_config() - Creates a batch_config classdef object containing the 
% properties that hold parameters for batch executing history template 
% batching scripts. 
%
% Notes: The batch_config structure is only translated into an object at
% the time of being displayed in the PropertyGrid GUI. Once that the GUI is
% closed it is translated back to a structure and is only handled as a
% structure by other functions and the workspace.
%
% See also: pop_runhtb(), pop_batch_edit(), propgrid2batchconfig()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts,
%                 and Brad Kennedy
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

function batch_config=init_batch_config()

batch_config.file_name='';
batch_config.exec_func='ef_current_base';
batch_config.replace_string={''};
batch_config.order=[];
        
batch_config.session_init='';
batch_config.job_name='';
batch_config.mfile_name='';
batch_config.job_init='';
batch_config.m_init='';
batch_config.submit_options={''};
batch_config.memory='';
batch_config.time_limit='';
batch_config.mpi='false';
batch_config.num_tasks='';
batch_config.threads_per_task='';
batch_config.software='matlab';
batch_config.program_options={''};

