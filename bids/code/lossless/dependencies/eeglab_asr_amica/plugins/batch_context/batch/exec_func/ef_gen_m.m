% ef_gen_m() - Based on job_struct parameters this function builds the *.m
% file that will be executed as a batch pipeline. This function is used on any
% job_struct cell whose software field is set to Octave, Matlab or None.
%
% Usage:
%  >> job_struct=ef_gen_m(job_struct)
%
% Required Inputs:
%   job_struct  = structure created by pop_runhtb that contains the
%   combined infomration required to submit a batch pipeline to the
%   SHARCNET scheduler.
%
% Outputs:
%   job_struct  = updated intput.
%
% See also: pop_runhtb(), ef_current_base(), ef_sqsub()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts, and
% Brad Kennedy
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

function job_struct = ef_gen_m(job_struct)

%% BUILD THE DIRECTORY FOR THE TIME M FILES IN THE
% LOG PATH OF THE CURRENT ANALYSIS_ROOT FOLDER...
%make directory named by history fname and date-time stamp.
root_hfn = job_struct.batch_hfn(1:strfind(job_struct.batch_hfn,'.')-1);
job_struct.m_path = sprintf('%s-%s', ...
    root_hfn, ...
    job_struct.starttime);
mkdir(fullfile(job_struct.context_config.log, job_struct.m_path));

%% MATLAB OR OCTAVE EXECUTION (BUILD M FILE)...
if ~strcmp(job_struct.batch_config.software, 'none') ... 
        || ~strcmp(job_struct.batch_config.exec_func, 'ef_sqsub')
   %% INITIATE BATCHINITSTR...
    batchInitStr='';
    
   %% M_INIT
   if exist(job_struct.batch_config.m_init, 'file');
       fid_minit = fopen(job_struct.batch_config.m_init, 'r');
       tmp_batchInitStr = fread(fid_minit, 'char');
       batchInitStr=[batchInitStr, char(tmp_batchInitStr')];
   else
       batchInitStr = [batchInitStr, job_struct.batch_config.m_init];
   end
   
    %% GET THE STRING FROM THE HTB FILES AND START BUILDING BATCHHISTSTR...
    %Create batchHistStr from the current HistFName file...
    [~, root_hfn, ~] = fileparts(job_struct.batch_hfn);
    fidRHT = fopen([job_struct.batch_hfp job_struct.batch_hfn ],'r');
    batchHistStr = char(fread(fidRHT,'char')');
    
    qsubstr='';
    
    disp(['Generating .m files in ', fullfile( ...
        job_struct.context_config.log, ...
        job_struct.m_path), '...']);
    %% START LOOP THROUGH DATA FILES...
    for bfni=1:length(job_struct.batch_dfn);
        % DO FOR EACH DATA FILE ... 
        %% INITIATE TMPHISTSTR...
        mfile_name = mfile_name_gen(job_struct.batch_config.mfile_name, ...
            job_struct.batch_dfn{bfni}, job_struct.batch_hfn, ...
            job_struct.batch_config.job_name);
        %% SWAP THE HISTORY STRING KEY STRINGS...        
        batchStr = batch_strswap([batchInitStr, batchHistStr], ...
            job_struct.batch_config, ...
            'datafname', job_struct.batch_dfn{bfni}, ...
            'datafpath', job_struct.batch_dfp, ...
            'mfile_name', mfile_name, ...
            'log', job_struct.context_config.log, ...
            'local_project', job_struct.context_config.local_project, ...
            'local_dependency', job_struct.context_config.local_dependency, ...
            'remote_project_archive', job_struct.context_config.remote_project_archive, ...
            'remote_project_work', job_struct.context_config.remote_project_work, ...
            'remote_dependency', job_struct.context_config.remote_dependency, ...
            'mount_archive', job_struct.context_config.mount_archive, ...
            'mount_work', job_struct.context_config.mount_work, ...
            'scheduler', job_struct.batch_config.exec_func(4:end));

        %BIDS standard file names have "-" characters... these need to be
        %changed to "_" in order for the m file to be executable.
        job_struct.batch_config.mfile_name(strfind(job_struct.batch_config.mfile_name,'-'))='_';
                
        if strcmp(job_struct.batch_config.software, 'none');
            batchStr = ['system(''', strtrim(batchStr), ''')'];
        end
        %% SAVE THE STRSWAPPED HISTORY STRING TO M FILE IN THE TIME STAMPED LOG PATH...
        % save cBatchFName m file...
        
        if isempty(job_struct.batch_config.mfile_name)
            job_struct.batch_config.mfile_name = ...
                job_struct.batch_config.job_name;
        end
        
        try
            c_mfn = key_strswap(job_struct.batch_config.mfile_name, ...
                'batch_dfn', char(job_struct.batch_dfn{bfni}));
            c_mfn = key_strswap(c_mfn, 'batch_hfn', char(job_struct.batch_hfn));
            c_mfn = [c_mfn, '.m'];
            c_mfn = strtrim(c_mfn);
        catch
            %If there sting is not acceptable default to:
            [~, root_dfn, ~] = fileparts(job_struct.batch_dfn{bfni});
            c_mfn=[root_hfn, '_', root_dfn, '.m'];
        end

        if strcmp(c_mfn, '.m')
            %If they did not use a batch config containing jobname default to:
            [~, root_dfn, ~] = fileparts(job_struct.batch_dfn{bfni});
            c_mfn = [root_hfn, '_', root_dfn, '.m'];
        end

        if length(c_mfn) >= 64
            error('Script name too long! Please change your job name config.')
        end
        
        %BIDS standard file names have "-" characters... these need to be
        %changed to "_" in order for the m file to be executable.
        c_mfn(strfind(c_mfn,'-'))='_';
        %job_struct.m_fname{bfni}=c_mfn;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %WRITE M FILE TO LOG PATH...
        fidM = fopen(fullfile(job_struct.context_config.log, ...
            job_struct.m_path,c_mfn),'w');

        fwrite(fidM, batchStr, 'char');
        fclose(fidM);
        
        job_struct.exec_str{bfni} = '';
    end
end
