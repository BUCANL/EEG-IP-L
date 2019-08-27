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

function version = eegplugin_interp_mont(fig,try_strings,catch_strings)
version = get_version('interp_mont', 'interp_mont1.0');
%% start up
addpath(genpath(fileparts(which(mfilename()))));

% Find "Tools" menu.
toolsmenu=findobj(fig,'label','Tools');

% Create cmd for warping chanlocs structure to corrdinate file location.
cmd='[EEG LASTCOM] = pop_warp_locs( EEG );';
finalcmdwl=[try_strings.no_check cmd catch_strings.store_and_hist];

% Create cmd for interpolating currentlocations to sites in coordinate file.
cmd='[EEG LASTCOM] = pop_interp_mont( EEG );';
finalcmdim=[try_strings.no_check cmd catch_strings.store_and_hist];

% Create cmd for rereferencing current data to the average of sites from a coordinate file.
cmd='[EEG LASTCOM] = pop_interp_ref( EEG );';
finalcmdir=[try_strings.no_check cmd catch_strings.store_and_hist];

% add "interpolate to coordinate file" submenu to "Tools" menu.
interpmenu=uimenu(toolsmenu,'label','Interpolate to coordinate file');

% add submenus to interpmenu.
uimenu(interpmenu,'label','Warp montage to the surface of sites in a coordinate file','callback',finalcmdwl);
uimenu(interpmenu,'label','Interpolate the data to sites in a coordinate file','callback',finalcmdim);
uimenu(interpmenu,'label','Rereference the data to the average of sites in a coordinate file','callback',finalcmdir);

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
