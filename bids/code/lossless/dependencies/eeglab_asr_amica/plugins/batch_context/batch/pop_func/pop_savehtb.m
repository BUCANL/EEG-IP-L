% pop_savehtb() - Saves the current dataset as a history template file.
%
%   Saves the current dataset's history field to a text editable file with
%   the extension "htb" (History Template Batching file). The history
%   template batching file is a text file containing an EEGLAB dataset
%   history that has been formated to be applied to several data files
%   sequentially. The formatting of the history template batching files
%   revolve around the input and output file names. More specifically, the
%   file names are replaced with "[batch_dfn]" [batch Data File Name] (eg. "InputFName.raw" =
%   "batch_dfn"). The file path string in the history template batch file
%   is replaced with "[batch_dfp]" [batch Data File Path].
%
%   Example dataset history conveted to htb format. This example loads an
%   existing dataset, performs ICA then saves the output to the hard drive:
%
%   dataset history =
%
%   EEG = pop_loadset( 'filename', '26CP_FHO.cat2.set', 'filepath', 'analysis/data');
%   EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
%   EEG = pop_saveset( EEG, 'filename','26CP_FHO_ica.set','filepath','analysis/data');
%   pop_savehtb( EEG, 'DefaultICA.htb', 'C:\Research\BUCANL\UW06\EmotionalFHO\ICA\Exploration\Drafts\InterpTest\');
%
%   resulting htb file string =
%
%   EEG = pop_loadset( 'filename', '[batch_dfn]', 'filepath', '[batch_dfp]');
%   EEG = pop_runica(EEG,  'icatype', 'runica', 'dataset',1, 'options',{ 'extended',1});
%   EEG = pop_saveset( EEG, 'filename','[batch_dfp,.,-2]_ica.set','filepath','[batch_dfp]');
%
%
%   Note:
%
%   1 - Running history template batch files that contain [batch_dfn] as the
%       input file name and the output file name will overwrite the data without
%       asking for permission.
%   3 - While the savehtb function attempts to format the current dataset
%       history to be compatible with the runhtb function, it
%       is advised to look over the htb file before batching procedures with
%       the pop_runhtb function. Some input values may need
%       to be replaced with variable names (eg. If input files have varying
%       numbers of channels a pop_function that requires as input the index
%       of the last channel will by default list the channel index, say "129".
%       In the htb file the "129" index value should be changed to the
%       variable name "EEG.nbchan").
%   4 - This function will only recognize the input file name from specific
%       data loading functions. The currently recognized load functions are;
%       pop_loadset, pop_readegi, pop_loadbv, pop_loadcnt or pop_ImportERPscoreFormat.
%
% Usage:
%   >>  savehtb( EEG, htb_fname, htb_fpath );

% Inputs:
%   EEG          - EEG structure.
%   htb_fname    - Name of template file.
%   htb_fpath    - Path of template file.

% Outputs:
%   write *.htb file to disk.
%
% See also:
%   pop_runhtb()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts and 
%                 Brad Kennedy
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


function com = pop_savehtb(EEG, htb_fname, htb_fpath)

com = ''; % this initialization ensure that the function will return something
% if the user press the cancel button

% display help if not enough arguments
% ------------------------------------
if nargin < 1
    help pop_savehtb;
    return;
end;

% pop up window
% -------------
if nargin < 2
    [htb_fname, htb_fpath] = uiputfile('*.htb', 'Save history template batch file as:', 'HistoryTemplate.htb');
end;
if isnumeric(htb_fname); return; end

% return the string command
% -------------------------
com = sprintf('pop_savehtb( %s, ''%s'', ''%s'');', inputname(1), htb_fname, htb_fpath);

%% Create "hist_str" from EEG.history.
hist_str = sprintf('%s', EEG.history);

%% find the last call to "pop_loadset" in "hist_str" and make that the new starting point.
Index_loadset = findstr(hist_str, 'EEG = pop_loadset');
if ~isempty(Index_loadset);
    hist_str = hist_str(Index_loadset(length(Index_loadset)):length(hist_str));
end
hist_str = strtrim(hist_str);

%% Create "load_line"
load_line = hist_str(1:find(double(hist_str) == 10, 1));
load_line_squotes = strfind(load_line, '''');

%% Create "load_fname", "RootFName" and "load_fpath".

%loadset
if ~isempty(strfind(load_line, 'EEG = pop_loadset'));
    load_fname = load_line(load_line_squotes(3) + 1:load_line_squotes(4) - 1);
    load_fpath = load_line(load_line_squotes(7) + 1:load_line_squotes(8) - 1);
end
%readegi
if ~isempty(strfind(load_line, 'EEG = pop_readegi'));
    load_fpath_fname = load_line(load_line_squotes(1) + 1:load_line_squotes(2) - 1);
    [fpath, fname, fext] = fileparts(load_fpath_fname);
    load_fname = [fname, fext];
    load_fpath = fpath;
end
%loadbv
if ~isempty(strfind(load_line, 'EEG = pop_loadbv'));
    load_line = strcat(load_line(1:find(load_line == '[', 1, 'first') - 3), ...
        load_line(find(load_line == ')', 1, 'last'):length(load_line)));
    hist_str = hist_str(find(double(hist_str) == 10):length(hist_str));
    hist_str = strcat(load_line, hist_str);
    load_fname = load_line(load_line_squotes(3) + 1:load_line_squotes(4) - 1);
    load_fpath = load_line(load_line_squotes(1) + 1:load_line_squotes(2) - 1);
end
%ERPscore
if ~isempty(strfind(load_line, 'pop_ImportERPscoreFormat')) ...
        || ~isempty(strfind(load_line, 'pop_ImportMULFormat'));
    load_fname = load_line(load_line_squotes(1) + 1:load_line_squotes(2) - 1);
    load_fpath = load_line(load_line_squotes(3) + 1:load_line_squotes(4) - 1);
end
%loadcnt
if ~isempty(strfind(load_line, 'EEG = pop_loadcnt'));
    load_fpath_fname = load_line(load_line_squotes(1) + 1:load_line_squotes(2) - 1);
    [fpath, fname, fext] = fileparts(load_fpath_fname);
    load_fname = [fname, fext];
    load_fpath = fpath;
end
%biosig
if ~isempty(strfind(load_line, 'EEG = pop_biosig'));
    load_fpath_fname = load_line(load_line_squotes(1) + 1:load_line_squotes(2) - 1);
    [fpath, fname, fext] = fileparts(load_fpath_fname);
    load_fname = [fname, fext];
    load_fpath = fpath;
end


%% Edit "hist_str" to allow batch sting replacment.
hist_str = strrep(hist_str, load_fpath, '[batch_dfp]');
hist_str = strrep(hist_str, load_fname, '[batch_dfn]');

%Replace strings containing '.' roots of the load_fname...
lfn_pind = strfind(load_fname, '.');
for i = 1:length(lfn_pind);
    lfn_p_name{i} = load_fname(1:lfn_pind(length(lfn_pind) - (i - 1)) - 1);
    hist_str = strrep(hist_str, lfn_p_name{i}, ['[batch_dfn,.,-', num2str(i), ']']);
end

%Replace strings containing '_' roots of the load_fname...
lfn_uind = strfind(load_fname, '_');
for i = 1:length(lfn_uind);
    lfn_u_name{i} = load_fname(1:lfn_uind(length(lfn_uind) - (i - 1)) - 1);
    hist_str = strrep(hist_str, lfn_u_name{i}, ['[batch_dfn,_,-', num2str(i), ']']);
end

%Replace instances of current directory...
currentDir = cd();
hist_str = strrep(hist_str, currentDir, '[batch_cd]');


%% Write "hist_str" in "*.htb" file to disk.
fidHTB = fopen([htb_fpath, htb_fname], 'w');
fprintf(fidHTB, '%s', hist_str);
fclose(fidHTB);

