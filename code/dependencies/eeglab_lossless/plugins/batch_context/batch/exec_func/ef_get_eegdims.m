% ef_get_eegdims() - gets dimensions of a given set file, we also cache
%                    these dimensions to avoid opening the file multiple
%                    times
%
% Usage:
%   >>  dimensions = ef_get_eegdims(dfpath, dfname)
%
% Inputs:
%   dfpath - data file path
%   dfname - data file name
%
% Outputs:
%   dimensions - struct with 'channels' and 'samples' members

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Mike Cichonski
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

function dimensions = ef_get_eegdims(dfpath, dfname)
    persistent allDims;
    if isempty(allDims)
        allDims = struct();
    end
    [~,name,~] = fileparts(dfname); % remove extension so filename can be used as a field (no '.' allowed)

    %BIDS standard file names have "-" characters... these need to be
    %changed to "_" in order for the m file to be executable.
    name(strfind(name,'-'))='_';
    if ~isfield(allDims, name)
        EEG_temp = pop_loadset('filename', dfname,'filepath', dfpath, 'loadmode', 'info');
        allDims.(name) = struct('channels', EEG_temp.nbchan, 'samples', EEG_temp.pnts);
    end
    dimensions = allDims.(name);
        
