% pop_loadbatchconfig() - A GUI for loading and ordering batch_config structures
% from file. The two step load procedure allows the user to select multiple 
% files from a browser then arrange the order within an edit field. 
%
% Usage:
%  >> pop_loadbatchconfig(fname,fpath)
%
% Graphical Interface: Accessed from the pop_runhtb GUI button "Load
% batch_config".
%
%   Batch configuration file: opens file browser to select *.cfg file(s),
%   then populated the edit field with the file name list where the order
%   of the files can be manipulated prior to opening them into the workspace.
%
%   Cancel: Ignore changes and close the GUI.
%
%   OK: Load the batch_config *.cfg files (in the order listed) into 
%   batch_config structure in the base workspace then close the GUI.
%
% Required Inputs:
%   fname  = List of file names to load into the batch_config structure.
%
%   fpath  = Path to the listed batch_config files listed in fname.
%
% Notes: If the inputs are empty launch the GUI.
%
% Outputs: Stores batch_config structure in the base workspace. 
%
% See also: pop_runhtb()

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

function pop_loadbatchconfig(fname,fpath)

if nargin < 1
    
    results=inputgui( ...
        'geom', ...
        {...
        {8 10 [0.05 0] [8 1]} ... %2
        {8 10 [0.05 1] [8 1]} ... %4
        {8 10 [0.05 2] [8 8]} ... %6
        }, ...
        'uilist', ...
        {...
        {'Style', 'pushbutton', 'string', 'Batch configuration file', ...
        'callback', ...
        ['path = ''*.cfg'';' ...
        'if exist(''context_config'', ''var''); path = [find_hints_context_config(context_config, ''config_dir'') path]; end;' ... 
        '[bcfgFName, bcfgFPath] = uigetfile(''*.cfg'',''Select batch configuration file:'',' ...
        'path,''multiselect'',''on'');', ...
        'if isnumeric(bcfgFName);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_bcp''),''string'',bcfgFPath);', ...
        'set(findobj(gcbf,''tag'',''edt_bcn''),''string'',bcfgFName);']} ... %2
        {'Style', 'edit', 'tag','edt_bcp'} ... %4
        {'Style', 'edit', 'max', 500, 'tag', 'edt_bcn'}, ... %6
        }, ...
        'title', 'Select batching parameters -- pop_runhtb()' ...
        );

    if isempty(results);return;end

    fpath=    results{1};
    fname=    results{2};
end;

if ~iscell(fname);
    fname={fname};
end

batch_state=[];
for i=1:length(fname)
    if isempty(batch_state);
        batch_config=evalin('base',['text2struct_bc(''',fullfile(fpath,fname{i}),''');']);
        batch_state=1;
    else
        tmp.batch_config=text2struct_bc(fullfile(fpath,fname{i}));
        batch_config=[batch_config,tmp.batch_config];
    end
end
assignin('base', 'batch_config',batch_config);






