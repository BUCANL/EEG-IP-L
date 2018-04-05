% read_jobs() - returns a cellstr of jobids from the given htb file
%
% Usage:
%   >>  out = read_jobs(driver, result_str)
%
% Inputs:
%   driver   - the driver we are using, should be subtype of ef_base_driver
%   job_spec - results of the output of running the submission script
%    
% Outputs:
%   out      - scheduler independent format for the concrete scheduler
%              implementation
%
% See also:
%   pop_runhtb

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
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

function out = read_jobs(~, result_str)
    expression = 'job (?<id>\d+)';
    id = regexp(result_str, expression, 'names');
    out = {id.id};
end