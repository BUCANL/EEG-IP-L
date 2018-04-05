% pop_runhtb() - Run history template on multiple data files.
% See runhtb for more details.
%
% Usage:
%   >>  com = pop_runhtb(execmeth,HistFName,HistFPath,BatchFName,BatchFPat);
%
% Inputs:
%   execmeth     - Execution method. "serial" = run batch serial mode using
%                  for loop, "parallel" = run batch in parallel mode using
%                  parfor loop (requires Matlab PCT).
%   HistFName    - Name of history template file.
%   HistFPath    - Path of history template file.
%   BatchFName   - Name of batch files.
%   BatchFPath   - Path of batch files
%    
% Outputs:
%   com             - Current command.
%
% See also:
%   savehtb 
%

% Copyright (C) <2006>  <James Desjardins>
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
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: pop_runhtb.m edit history...
%

% get rid of globals


function vised_config = pop_edit_vised_config(fname)

try parameters = evalin('base', 'vised_config');
    vised_config=parameters;
catch %if nonexistent in workspace
    vised_config=init_vised_config;
end

PropGridStr=['global vcp;' ...
    'properties=visedconfig2propgrid();' ...
    'properties = properties.GetHierarchy();' ...
    'vcp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.05 .1 .91 .8]);' ...
    ];

% pop up window
% -------------
    
results=inputgui( ...
    'geom', ...
    {...
    {6 24 [0 0] [1 1]} ... %1 this is just to control the size of the GUI
    {6 24 [0.05 0] [2 1]} ... %2
    {6 24 [4 0] [1 1]} ... %4
    {6 24 [5 0] [1 1]} ... %5
    }, ...
    'uilist', ...
    {...
    {'Style', 'text', 'tag','txt_vcfp','string',blanks(16)} ... %1 this is just to control the size of the GUI
    {'Style', 'pushbutton', 'string', 'Load vised config', ...
    'callback', ...
    ['[configFName, configFPath] = uigetfile(''*.cfg'',''Select vised configuration file:'',''*.cfg'',''multiselect'',''off'');', ...
    'if isnumeric(configFName);return;end;', ...
    'evalin(''base'',[''vised_config=text2struct_ve(fullfile(configFPath,configFName));'']);', ...
    PropGridStr]} ... %2
    {'Style', 'pushbutton','string','Save as', ...
    'callback',['[cfgfname,cfgfpath]=uiputfile(''*.*'',''Vised configuration file'');', ...
    'global vcp;  vised_config=propgrid2visedconfig(vcp);' ...
    'struct2text_ve(vised_config, fullfile(cfgfpath,cfgfname));']}, ...
    {'Style', 'pushbutton','string','Clear','callback',['vised_config=init_vised_config;',PropGridStr]}, ...
    }, ...
    'title', 'Vised configuration -- pop_edit_vised_config()',...%, ...
    'eval',PropGridStr ...
    );

global vcp;
vised_config=propgrid2visedconfig(vcp);
assignin('base', 'vised_config',vised_config);
clear -global vcp
