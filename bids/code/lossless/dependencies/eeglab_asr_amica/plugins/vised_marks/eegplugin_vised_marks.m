% eegplugin_vised_marks() -Include the appopriate path to access plugin 
%functions and add the relevant vised_marks callbacks to EEGLAB GUI menu
%items at EEGLAB start time.
%
%
% Usage:
%  >> eegplugin_vised_marks(fig,try_strings,catch_strings);
%
% Graphical Interface:
%This function adds the following menu items to the EEGLAB GUI at start
%time:
%   File >
%       vised configuration
%   Edit >
%       Visually edit in scroll plot
%   Tools >
%       Marks >
%           Epoch/concatenate data >
%               Epoch data into regular intervals
%               Concatenate epochs into continuous data
%           Edit marks >
%               Collect "reject" structure into "marks" structure
%               Mark flag gaps
%               Mark event gaps
%               Combine flag types
%               Add/remove/clear marks flag type
%           Select data
%           
% Required Inputs:
%   fig             = handle of the main EEGLAB window
%   try_string      = see: https://sccn.ucsd.edu/wiki/A07:_Contributing_to_EEGLAB#Creating_an_eegplugin_function
%   catch_string    = see: https://sccn.ucsd.edu/wiki/A07:_Contributing_to_EEGLAB#Creating_an_eegplugin_function
%
% Optional Inputs:
%
% Outputs:
%
% Notes: This file is only called by eeglab.m at start time.
%
% Typical use:
%
% See also: eeglab, pop_vised

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, and Andrew Lofts
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




function version = eegplugin_vised_marks(fig, try_strings, catch_strings)

version = get_version('vised_marks', 'vised_marks1.0.0');
%% start up
addpath(genpath(fileparts(which('eegplugin_vised_marks.m'))));

%% vised
% find EEGLAB tools menu.
% ---------------------
filemenu=findobj(fig,'label','File');
editmenu=findobj(fig,'label','Edit');

% Create "pop_vised" callback cmd.
%---------------------------------------
VisEd_cmd='[EEG,LASTCOM] = pop_vised(EEG,''pop_gui'',''on'');';
finalcmdVE=[try_strings.no_check VisEd_cmd catch_strings.add_to_hist];

%CONFIG
uimenu(filemenu, 'Label', 'Vised configuration','separator','on', ...
                 'callback','vised_config=pop_edit_vised_config;');
             
% add "Visual edit" submenu to the "Edit" menu.
%--------------------------------------------------------------------
uimenu(editmenu, 'label', 'Visually edit in scroll plot', 'callback', finalcmdVE);

%%marks
%--------------------------------------------------------------------------
% Get File menu handle...
%--------------------------------------------------------------------------
toolsmenu=findobj(fig,'Label','Tools');

%--------------------------------------------------------------------------
% Create "Batch" menu.
% -------------------------------------------------------------------------
marksmenu  = uimenu( toolsmenu, 'Label', 'Marks','separator','on');


% -------------------------------------------------------------------------
% Create submenus
%--------------------------------------------------------------------------
%
cmd='[EEG,LASTCOM] = pop_continuous2epochs(EEG);';
finalcmdC2E=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM] = pop_epochs2continuous(EEG);';
finalcmdE2C=[try_strings.no_check cmd catch_strings.new_and_hist];


cmd='LASTCOM=''EEG=reject2marks(EEG);'';eval(LASTCOM);';
finalcmdR2M=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_flag_gap(EEG);';
finalcmdMFG=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd='[EEG,LASTCOM]=pop_marks_event_gap(EEG);';
finalcmdMEG=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd=['if ~isfield(EEG,''marks'');', ...
    '    if isempty(EEG.icaweights);', ...
    '        EEG.marks=marks_init(size(EEG.data));', ...
    '    else;', ...
    '        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));', ...
    '    end;', ...
    'end;', ...
    '[EEG,LASTCOM]=pop_marks_merge_labels(EEG);'];
finalcmdCFM=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd=['if ~isfield(EEG,''marks'');', ...
    '    if isempty(EEG.icaweights);', ...
    '        EEG.marks=marks_init(size(EEG.data));', ...
    '    else;', ...
    '        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));', ...
    '    end;', ...
    'end;', ...
    '[EEG.marks]=pop_marks_add_label(EEG.marks);'];
finalcmdARF=[try_strings.no_check cmd catch_strings.new_and_hist];

cmd=['if ~isfield(EEG,''marks'');', ...
    '    if isempty(EEG.icaweights);', ...
    '        EEG.marks=marks_init(size(EEG.data));', ...
    '    else;', ...
    '        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));', ...
    '    end;', ...
    'end;', ...
    'EEG=pop_marks_select_data(EEG);'];
finalcmdMPD=[try_strings.no_check cmd catch_strings.new_and_hist];

% Add submenus to the "marks" submenu.
%-------------------------------------
epochmenu=uimenu(marksmenu,'label','epoch/concatenate data');
editmenu=uimenu(marksmenu,'label','edit marks');

uimenu(epochmenu,'label','Epoch data into regular intervals', ...
                'callback',finalcmdC2E, ...
                'userdata', 'startup:off;epoch:off;continuous:on');
uimenu(epochmenu,'label','Concatenate epochs into continuous data', ...
                'callback',finalcmdE2C, ...
                'userdata','startup:off;epoch:on;continuous:off');

uimenu(editmenu,'label','Collect ''reject'' structure into ''marks'' structure','callback',finalcmdR2M);
uimenu(editmenu,'label','Mark flag gaps','callback',finalcmdMFG);
uimenu(editmenu,'label','Mark event gaps','callback',finalcmdMEG);
uimenu(editmenu,'label','Combine flag types','callback',finalcmdCFM);
uimenu(editmenu,'label','Add/remove/clear marks flag type','callback',finalcmdARF);


uimenu(marksmenu,'label','Select data','callback',finalcmdMPD);

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
