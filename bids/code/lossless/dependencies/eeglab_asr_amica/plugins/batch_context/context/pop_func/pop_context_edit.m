% pop_context_edit() - A GUI for creating new, loading old, editing and
% saving context_config structures.
%
% Usage:
%  >> pop_context_edit
%
% Graphical Interface: Accessed from EEGLAB menu File > Context configuration
%
%   Load context config: Opens file browser to select *.cfg file.
%
%   Save as: Saves the context_config structure to a *.cfg file.
%
%   Clear: Clear the current context_config structure from the
%   PropertyGrig field and create a new empty context_config structure.
%
%   Cancel: Ignores changes and close the GUI.
%
%   OK: Applies the current state of all PropertyGrid fields to the
%   context_config structure in the base workspace then close the GUI.
%
% Required Inputs: Defaults to loading the context_config structure from
% the base workspace if present.
%
% Outputs: Stores context_config structure in the base workspace.
%
% Notes: As with all PropertyGrid GUIs any edited field must be terminated
% (e.g. click on another field or Enter) before the inputs will be registered.
% If a field is modified without a termination the edit will be ignored
% when OK is clicked.
%
% See also: pop_runhtb()

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

function context_config = pop_context_edit

com = ''; % this initialization ensure that the function will return something
% if the user press the cancel button

% Get cell array of base workspace variables. It would be cleaner and scale
% easier if evalins output was a structure. But for now, parsing the cell
% array leads to less immediate changes to the code.
try parameters = evalin('base', 'context_config');
    context_config=parameters;
catch %if nonexistent in workspace
    context_config=init_context_config;
end

PropGridStr=['global ccp;' ...
    'context_config = evalin(''caller'', ''context_config'');' ... 
    'properties=contextconfig2propgrid(context_config);' ...
    'properties = properties.GetHierarchy();' ...
    'ccp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.05 .26 .9 .64]);' ...
    ];

% pop up window
% -------------
if nargin < 4
    
    results=inputgui( ...
        'geom', ...
        {...
        {6 22 [0 0] [1 1]} ... %1 this is just to control the size of the GUI
        {6 22 [0.05 0] [2 1]} ... %2
        {6 22 [4.8 0] [1.13 1]} ... %3
        {6 22 [0.05 18.5] [1 1]} ... %4
        {6 22 [.9 18.5] [1 1]} ... %5
        {6 22 [0.05 20] [1 1]} ... %6
        {6 22 [.9 20] [5 1]} ... %6
        {6 22 [0.05 21] [1 1]} ... %2.5
        {6 22 [.9 21] [5 1]} ... %6
        }, ...
        'uilist', ...
        {...
        {'Style', 'text', 'tag','txt_ccfp','string',blanks(30)} ... %1 this is just to control the size of the GUI
        {'Style', 'pushbutton', 'string', 'Load context config', ...
        'callback', ...
        ['[configFName, configFPath] = uigetfile(''*.cfg'',''Select Context configuration file:'',''*.cfg'',''multiselect'',''off'');', ...
        'if isnumeric(configFName);return;end;', ...
        'context_config=text2struct_cc(fullfile(configFPath,configFName));' ...
        'global ccp;' ...
        'properties=contextconfig2propgrid(context_config);' ...
        'properties = properties.GetHierarchy();' ...
        'ccp = PropertyGrid(gcf,' ...
        '''Properties'', properties,' ...
        '''Position'', [.05 .26 .9 .64]);']} ... %11 context config push button} ... %2
        {'Style', 'pushbutton', 'string', 'get dir to clipboard', ...
        'callback', ...
        'dirname=uigetdir;clipboard(''copy'',dirname);'} ... %25
        {'Style', 'pushbutton','string','Save as', ...
        'callback',['[cfgfname,cfgfpath]=uiputfile(''*.*'',''Context configuration file'');', ...
        'global ccp;' ...
        'context_config=propgrid2contextconfig(ccp);', ...
        'struct2text(context_config,fullfile(cfgfpath,cfgfname));']},...
        {'Style', 'pushbutton','string','Clear','callback',['context_config=init_context_config;',PropGridStr]}, ...
        {'Style', 'pushbutton','string','System', ...
        'callback',['evalstr=strcat(''system('''''',get(findobj(gcbf,''tag'',''edt_syscmd''),''string''),'''''');'');',...
        'disp(evalstr);', ...
        'eval(evalstr{:});']}, ...
        {'Style', 'edit', 'tag','edt_syscmd'}, ... %9
        {'Style', 'pushbutton', 'string', 'Refresh', ...
        'callback', ...
        'close(gcf);context_config=pop_context_edit;'} ... %2
        {'Style', 'popup', 'string', context_config.system_cmds, 'value',1,'tag', 'pop_syscmd', ...
        'callback',['tmpcmds=get(findobj(gcbf,''tag'',''edt_syscmd''),''string'');', ...
        'tmpval=get(findobj(gcbf,''tag'',''pop_syscmd''),''value'');', ...
        'set(findobj(gcbf,''tag'',''edt_syscmd''),''string'', context_strswap(eval(''context_config.system_cmds(tmpval)'')));']} ...
        }, ...
        'title', 'Context configuration -- pop_context_edit()',...%, ...
        'eval',PropGridStr ...
        );
    
    if isempty(results);return;end
    
    %%%%%%%%%%%%%%%
    % try to get rid of this. it serves to make sure that the base
    % workspace has the most recent context_config structure
    % maybe there is a way to use assignin to return the updated structure
    % to workspace without declaring ccp global here
    global ccp
    context_config=propgrid2contextconfig(ccp);
    assignin('base', 'context_config',context_config);
    clear -global cpp
    %%%%%%%%%%%%%%
    
end;

