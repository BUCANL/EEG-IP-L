% find_hinsts_context_config() - returns the value of the varname from
%                                context_config.misc
%
% Usage:
%   >> rval = find_hints_context_config(context_config, varname)
%
% Inputs:
%   context_config - context_config from batch context
%   varname        - name of variable in [<variable>] any/string
%
% Outputs:
%   rval           - the string from the context_config.misc right side
%   

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
function rval = find_hints_context_config(context_config, varname)
    rval = '';
    if ~exist('context_config', 'var') || isempty(context_config.misc)
        return;
    end
    exp = '\[(?<key>\w+)\]\s+(?<val>\S+)';
    tokens = regexp(context_config.misc, exp, 'names');
    if isempty(tokens{1})
        return;
    end
    for i=1:length(tokens)
        if strcmp(tokens{i}.key, varname)
            rval = [tokens{i}.val '/'];
            return;
        end
    end
end

