% format_scheduler() - returns a string that represents a line for a
%                      single input data file on the given scheduler
%
% Usage:
%   >>  out = format_scheduler(driver, job_spec)
%
% Inputs:
%   driver   - the driver we are using, should be subtype of ef_base_driver
%   job_spec - scheduler independent format specified in
%              @ef_base_driver/submit_line
%    
% Outputs:
%   out      - scheduler dependent format for the concrete scheduler
%              implementation
%
% See also:
%   @ef_base_driver/submit_line

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

function out = format_scheduler(~, ~)
    error('The format_scheduler function MUST be overridden by drivers');
end
