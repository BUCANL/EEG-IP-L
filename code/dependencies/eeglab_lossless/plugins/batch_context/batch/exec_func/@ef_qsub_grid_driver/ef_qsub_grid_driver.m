% ef_qsub_grid_driver() - subclass of ef_base_driver that implements a driver
%                         sharcnet scheduler based on qsub
%
% Usage:
%   >>  driver = ef_qsub_grid_driver()
%    
% Outputs:
%   driver  - for use with a scheduler
%
% See also:
%   @ef_qsub_driver/format_scheduler
%   @ef_qsub_driver/read_jobs

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
% Suite 330, Boston, MA  02

function obj = ef_qsub_grid_driver()
   obj = class(struct(), 'ef_qsub_grid_driver', ef_base_driver());
end
