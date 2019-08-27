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

function batch_config=text2struct_bc(fname)

batch_config = init_batch_config();

batch_config.exec_func='';
batch_config.software='';

keywords = fieldnames(batch_config);
% Backwards compatibility
backwards_compat = struct('qsub_options', 'submit_options', ...
                          'num_processors', 'num_tasks');
backwards_fields = fields(backwards_compat);
keywords = [keywords; backwards_fields];

% Open file
fileID = fopen(fname);
C = fread(fileID, '*char')';
t = config_parse(C);
fclose(fileID);

for i=1:length(keywords)
    kw = keywords{i};
    % Child elements
    key_val = t.get_children_contents_of_match(t, ...
        @(x) strcmp(x, kw), 1);
    
    if isempty(key_val)
        continue
    end
    % key_val is always a cell array
    
    % Backwards compatibility check, changes any item in backwards_compat
    if isfield(backwards_compat, kw)
        kw = backwards_compat.(kw);
    end
    
    if iscell(batch_config.(kw))
        batch_config.(kw) = key_val';
    elseif ischar(batch_config.(kw))
        if numel(key_val) ~= 1
            error('key_val must be one sized for %s which is a char', ...
                kw)
        end
        batch_config.(kw) = key_val{1};
    elseif isnumeric(batch_config.(kw))
        batch_config.(kw) = str2num(key_val{:});
    end
end
