% config_parse_multilevel() -
%                    parses the input text by line based on the number of
%                    indentantion specifies if it is on the root level
%                    or any level below that
%
% Usage:
%  >> out = config_parse(in)
%
% Inputs:
%     in - text, delimited by newlines with indentation specifying the
%          depth it resides in the tree
%
% Outputs:
%   out  - A tree created by tree_new that has a root a index 1 with
%          top-level children and all levels below that
%
% See:
%   tree_new
%   config_parse

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

function out = config_parse_multilevel(in)
    % in is a string or maybe a file descriptor
    scan = regexp(in, '[\n]+', 'split');

    scan = scan(~cellfun(@isempty, strtrim(scan)));

    % Get first non space
    % TODO(mae) both spaces and tabs
    indent_vals = cellfun(@max, strfind(scan, sprintf('\t')), 'UniformOutput', false);
    %indent_vals = cellfun(@max, strfind(scan, sprintf(' ')), 'UniformOutput', false);

    % Adjust indexes
    indent_vals = cellfun(@sub_one_or_zero, indent_vals, 'UniformOutput', false);

    scan = strtrim(scan);

    t = tree_new();
    [t, ~] = t.add(t, 1, scan{1});

    parents_nodes = [1, 2];
    parents_lines = [1];

    for i=2:numel(indent_vals)
        % Indent increased
        while ~isempty(parents_lines) ... 
                && indent_vals{parents_lines(end)} >= indent_vals{i}
            parents_lines = parents_lines(1:end-1);
            parents_nodes = parents_nodes(1:end-1);
        end
        [t, node] = t.add(t, parents_nodes(end), scan{i});
        parents_nodes(end+1) = node;
        parents_lines(end+1) = i;
    end

    out = t;

end   
    
function x = sub_one_or_zero(x)
    if isempty(x)
        x = 0;
    end
end

