% eegplugin_batch_context() -Include the appropriate path to access plugin 
%functions and add the relevant batch_context functions to EEGLAB GUI menu
%items at EEGLAB start time.
%
% Usage:
%  >> [] = eegplugin_batch_context(fig,try_strings,catch_strings);
%
% Graphical Interface:
%This function adds the following menu items to the EEGLAB GUI at start time:
%   File >
%       context configuration
%       batch >
%           Save History Template Batching file (*.htb)
%           Run history template batch
%           Batch configuration
%
% Required Inputs:
%   fig             = handle of the main EEGLAB window
%   try_string      = see: https://sccn.ucsd.edu/wiki/A07:_Contributing_to_EEGLAB#Creating_an_eegplugin_function
%   catch_string    = see: https://sccn.ucsd.edu/wiki/A07:_Contributing_to_EEGLAB#Creating_an_eegplugin_function
%
% Notes: This file is only called by eeglab.m at start time.
%
% See also: eeglab(), pop_runhtb()

%Copyright (C) 2013 BUCANL
%
%Code originally written by James A. Desjardins with contributions from 
%Allan Campopiano and Andrew Lofts, supported by NSERC funding to 
%Sidney J. Segalowitz at the Jack and Nora Walker Canadian Centre for 
%Lifespan Development Research (Brock University), and a Dedicated Programming 
%award from SHARCNet, Compute Ontario.
%
%This program is free software; you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation; either version 2 of the License, or
%(at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program (LICENSE.txt file in the root directory); if not, 
%write to the Free Software Foundation, Inc., 59 Temple Place,
%Suite 330, Boston, MA  02111-1307  USA



function version = eegplugin_batch_context(fig,try_strings,catch_strings)

version = get_version('batch_context', 'batch_context1.0.0');

% Adding to path. Skip property grid if it is already found.
currentDir = fileparts(which(mfilename()));
pathPiece = genpath(currentDir);
if exist('PropertyGrid')
    warning('PropertyGrid was already found. Skipping.');
    rmStr = [currentDir '/external/PropertyGrid:'];
    pathPiece = strrep(pathPiece,rmStr,'');
end

addpath(pathPiece);

%--------------------------------------------------------------------------
% Get File menu handle...
%--------------------------------------------------------------------------
editmenu=findobj(fig,'label','File');


%% context menu
%uimenu(filemenu,'Label','Context configuration', ...
%                'separator','on', ...
%                'callback','CONTEXT_CONFIG=pop_context_edit;');

%% batch menu
try
    batchmenu  = uimenu( editmenu, 'Label', 'Batch','separator','on', 'position',length(editmenu.Children) - 2);
catch
    batchmenu  = uimenu( editmenu, 'Label', 'Batch','separator','on');
end

% create menu commands
% run history template batch...
cmd='pop_runhtb();';
finalcmdRHT=[try_strings.no_check cmd catch_strings.store_and_hist];

% save history template batch file...
cmd='LASTCOM = pop_savehtb(EEG);';
finalcmdSHT=[try_strings.no_check cmd catch_strings.store_and_hist];


% Add submenus to the "Batch" submenu.
%-------------------------------------
uimenu(batchmenu,'label','Save History Template Batching file (*.htb)','callback',finalcmdSHT);
uimenu(batchmenu,'label','Run history template batch','callback',finalcmdRHT);

uimenu(batchmenu,'Label','Batch configuration', ...
                'callback','batch_config=pop_batch_edit;');

uimenu(batchmenu,'Label','Context configuration', ...
                'callback','context=pop_context_edit;');
            
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
