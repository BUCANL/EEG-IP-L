% eegplugin_interp_mont() - EEGLAB plugin for interpolating data to locations
%                       found in coordinate file recognized by readlocs.
%
% Usage:
%   >> eegplugin_interp_mont(fig, try_strings, catch_stringss);
%
% Inputs:
%   fig            - [integer]  EEGLAB figure
%   try_strings    - [struct] "try" strings for menu callbacks.
%   catch_strings  - [struct] "catch" strings for menu callbacks.
%

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James Desjardins
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

function version = eegplugin_other_functions(fig,try_strings,catch_strings)
version = get_version('other_functions', 'other_functions1.0');
%% start up
addpath(genpath(fileparts(which(mfilename()))));

end
function version = get_version(prefix, fallback)
    version = fallback;
    [curdir, ~, ~] = fileparts(which(mfilename()));
    versionpath = fullfile(curdir, 'VERSION');
    if ~exist(versionpath, 'file')
        return;
    end
    fid = fopen(versionpath);
    if fid == -1
        return;
    end
    text = deblank(fread(fid, '*char')');
    fclose(fid);
    if text(1) == 'v'
        version = [prefix text(2:end)];
    else
        version = [prefix text];
    end
end
