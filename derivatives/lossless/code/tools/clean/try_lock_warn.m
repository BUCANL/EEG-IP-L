% try_lock_warn() - basic error prone directory lock
%
% Usage:
%   >>  lockname = try_lock_warn(dirn);
%
% Inputs:
%   dirn    - file to place the lock
%
% Outputs:
%   lockname - the lock file if successful, empty matrix if not

%
% See also:
%   pipeline_clean pipeline-clean.sh

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


function lockname = try_lock_warn(dirn)
    lockname = [];
    if nargin < 1
        dirn = '.';
    end
    fname = 'pipeline.%s.lock';
    dict = '0123456789abcdef';
    perm = dict(randi(numel(dict), 12, 1));
    fname = sprintf(fname, perm);
    dirinfo = dir(dirn);
    
    expression = 'pipeline\.[0-9a-f]+\.lock';
    index = regexp({dirinfo.name}, expression, 'ONCE');
    if any(~cellfun(@isempty,index))
        % Already locked
        return;
    end
    fid = fopen(fname, 'w');
    if fid == -1
        error(['Was unable to open %s to lock dir' ...
            'this could be a rare race condition'], fname);
    end
    fprintf(fid, 'try_lock_warn lock file, delete if stale\n');
    fclose(fid);
    % Race conditions could occur, they shouldn't be that dangerous however
    lockname = fname;
end

