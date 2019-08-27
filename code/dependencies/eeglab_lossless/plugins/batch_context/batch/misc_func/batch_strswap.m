% batch_strswap() - Based on the batch_config.replace_string field and the optional inputs 
% that are related to context_config. This function swaps key strings in a string
% array. This function is called by ef_gen_m to take the History Template Batch (*.htb) file
% and replaces the relevant key string instances with parameters from
% batch_config.replace_strings and context_config.
%
% Usage:
%  >> tmp_histstr=batch_strswap(tmp_histstr,batch_config,varargin)
%
% Required Inputs:
%   tmp_histstr   = String obtained from reading a History Template Batch
%                   file (*.htb) that contains key strings to be swapped (e.g.
%                   [batch_dfn]).
%
%   batch_config  = Structure containing the replace_strings field. This
%                   field contains key string pairs that define portions of
%                   a string array that will be replaced with variables. The 
%                   form of the key string pairs are a cell array of strings 
%                   such that each string is a comma separated key val pair 
%                   (e.g. {'[key1],val1';key2,val2'}). Keys in the text array
%                   are strings surrounded by brackets (e.g. [keystring]). Keys 
%                   listed in the replace_strings field do not require brackets.
%
% Optional Inputs:
%   datafname        = The name of the data file. This is swapped into any 
%   instance of [batch_dfn] within the tmp_histstr input array. This is
%   typically obtained via the data file selection in pop_runhtb (EEGLAB
%   menu File > Batch > Run history template batch).
%
%   datafpath        = The name of the data path. This is swapped into any 
%   instance of [batch_dfp] within the tmp_histstr input array. This is
%   typically obtained via the data file selection in pop_runhtb (EEGLAB
%   menu File > Batch > Run history template batch).
%
%   log              = The name of the log path (where standard output files 
%   are sent). This is swapped into any instance of [batch_dfp] within the 
%   tmp_histstr input array. This is typically obtained from
%   context_config.log.
%
%   local_project    = The name of the absolute root path of the current 
%   study folder structure. This is swapped into any instance of 
%   [local_project] within the tmp_histstr input array. This is typically 
%   obtained from context_config.log.
%
%   local_dependency = The name of the absolute or relative path (from 
%   local_project) of the folder containging functions that need to be 
%   added to the Octave/Matlab path. This is swapped into any instance of 
%   [local_dependency] within the tmp_histstr input array. This is typically 
%   obtained from context_config.local_dependency. 
%
%   remote_project_archive = The name of the absolute path of an archive 
%   folder at the remote location. This is swapped into any instance of 
%   [remote_project_archive] within the tmp_histstr input array. This is 
%   typically obtained from context_config.remote_project_archive.
%
%   remote_project_work = The name of the absolute path of the work 
%   folder at the remote location. This is swapped into any instance of 
%   [remote_project_work] within the tmp_histstr input array. This is 
%   typically obtained from context_config.remote_project_work.
%
%   remote_dependency = The name of the absolute path of the dependency 
%   folder at the remote location. This is swapped into any instance of 
%   [remote_dependency] within the tmp_histstr input array. This is 
%   typically obtained from context_config.remote_dependency.
%
%   mount_archive = The name of the absolute or relative path (from 
%   local_project) of the folder in which to mount the remote archive 
%   directory (remote_project_archive). This is swapped into any instance of 
%   [mount_archive] within the tmp_histstr input array. This is typically 
%   obtained from context_config.mount_archive.
%
%   mount_work = The name of the absolute or relative path (from 
%   local_project) of the folder in which to mount the remote work 
%   directory (remote_project_work). This is swapped into any instance of 
%   [mount_work] within the tmp_histstr input array. This is typically 
%   obtained from context_config.mount_work.
%
% Outputs:
%   tmp_histstr = updated intput in which instances of key strings have
%                 been swapped with their respective val strings.
%
% See also: pop_runhtb(), ef_gen_m(), key_strswap()

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


function tmp_histstr=batch_strswap(tmp_histstr,batch_config,varargin)

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('batch_strswap() error: calling convention {''key'', value, ... } error'); return;
end;

% data options...
try g.datafname; catch, g.datafname='';end
try g.datafpath; catch, g.datafpath='';end
try g.log; catch, g.log='';end
try g.local_project; catch, g.local_project='';end
try g.local_dependency; catch, g.local_dependency='';end
try g.remote_project_archive; catch, g.remote_project_archive='';end
try g.remote_project_work; catch, g.remote_project_work='';end
try g.remote_dependency; catch, g.remote_dependency='';end
try g.mount_archive; catch, g.mount_archive='';end
try g.mount_work; catch, g.mount_work='';end
try g.scheduler; catch, g.scheduler='';end

%% MODIFY TMPHISTSTR...
%perform replace_string{} swap...
for rpi=1:length(batch_config.replace_string);
    if ~isempty(batch_config.replace_string{rpi});
        cs=strfind(batch_config.replace_string{rpi},',');
        if ~isempty(cs);
            str1=strtrim(batch_config.replace_string{rpi}(1:cs(1)-1));
            if strcmp(str1([1,end]),'[]');
                keystr=str1;
                swapstr=strtrim(batch_config.replace_string{rpi}(cs(1)+1:end));
            else
                keystr=['[',str1,']'];
                swapstr=strtrim(batch_config.replace_string{rpi}(cs(1)+1:end));
            end
        end
        if ~isempty(strfind(tmp_histstr,keystr));
            tmp_histstr=strrep(tmp_histstr, ...
                keystr, ...
                swapstr);
        end
    end
end

%% swap HistStr keyPack strings...
% batch_dfn
tmp_histstr=key_strswap(tmp_histstr,'batch_dfn',g.datafname);
% batch_dfp
tmp_histstr=key_strswap(tmp_histstr,'batch_dfp',g.datafpath);
% batch_dfn
tmp_histstr=key_strswap(tmp_histstr,'mfile_name',g.mfile_name);
% current_dir
tmp_histstr=key_strswap(tmp_histstr,'batch_cd',cd);
% log
tmp_histstr=key_strswap(tmp_histstr,'log',g.log);
% local_project
tmp_histstr=key_strswap(tmp_histstr,'local_project',g.local_project);
% local_dependency
tmp_histstr=key_strswap(tmp_histstr,'local_dependency',g.local_dependency);
% remote_project_archive
tmp_histstr=key_strswap(tmp_histstr,'remote_project_archive',g.remote_project_archive);
% remote_project_work
tmp_histstr=key_strswap(tmp_histstr,'remote_project_work',g.remote_project_work);
% remote_dependency
tmp_histstr=key_strswap(tmp_histstr,'remote_dependency',g.remote_dependency);
% mount_archive
tmp_histstr=key_strswap(tmp_histstr,'mount_archive',g.mount_archive);
% mount_work
tmp_histstr=key_strswap(tmp_histstr,'mount_work',g.mount_work);
% scheduler
tmp_histstr=key_strswap(tmp_histstr,'scheduler',g.scheduler);
