% pipeline_clean() - Cleanup logs directory and preproc directory removing
%                    logs and extra data for successful jobs
%
% Usage:
%   >>  pipeline_clean(datafile, mfilename, logs_dir, options, varargin);
%
% Inputs:
%   datafile    - the data file name, i.e. 'Babysib_601'
%   mfilename   - the mfile name, i.e. 'babysib_601_init'
%   logs_dir    - expression that matches logs directory in analysis/log
%                 i.e. '2017-07-18T15-46-42'
%   options     - structure that matches the internal structure used for
%                 options see top of source code for valid fields
%   varargin    - key value options, must be multiple of 2
%                 seperate by commas, key and value are seperate strings
%
% See also:
%   try_lock_warn, pipeline-clean.sh

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
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

function pipeline_clean(datafile, mfilename, logs_dir, options, varargin)

%% Default options
    d_options.preproc_amica_param = true;
    d_options.preproc_amicaout = true;
    d_options.preproc_concat_data = true;
    d_options.preproc_concat_asr = false;
    d_options.preproc_sa = true;
    d_options.preproc_sa_purge = true;
    d_options.preproc_asr = true;
    d_options.preproc_asr_purge = true;
    d_options.preproc_compart_data_purge = true;
    d_options.preproc_compart_data = true;
    d_options.preproc_dip = false;
    
    d_options.trash_root = true;
    d_options.zip_successful_logs = true;
    d_options.delete_successful_logs = false;
    
    % gzip is faster but less effective
    d_options.use_system_xz = true;
    d_options.use_system_gzip = false;
    d_options.use_zip = false;
    
    % Merge options into opts
    if nargin == 3 || (nargin == 4 && isempty(options))
        opts = d_options;
    end
    if nargin > 3 && ~isempty(options)
        opts = merge_struct(d_options, options);
    end
    if nargin > 4
        if mod(numel(varargin), 2) ~= 0
            error('varargin needs to have an even number of elements');
        end
        optt = opts;
        clear opts;
        opts = merge_struct(optt, struct(varargin{:}));
    end
    
    % Verify success
    wassuccessful = pipeline_success(datafile, mfilename, logs_dir);
    if ~wassuccessful
        error('pipeline was not successful, refusing to cleanup/delete progress files');
    end
    
    preproc = fullfile('analysis', 'data', '2_preproc');
    
    %% Remove amica files/dirs
    logging_log('INFO', 'Removing amica temp files ifset');
    remove_ifset(preproc, [datafile '_A.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_B.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_C.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_D.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_E.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_F.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_asrinit.param'], opts.preproc_amica_param);
    remove_ifset(preproc, [datafile '_init.param'], opts.preproc_amica_param);
    
    % Octave matlab compat
    if exist('confirm_recursive_rmdir', 'builtin')
        pval = confirm_recursive_rmdir();
    end
    
    remove_dir_ifset(preproc, [datafile '_amicaout_A'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_B'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_C'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_D'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_E'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_F'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_init'], opts.preproc_amicaout);
    remove_dir_ifset(preproc, [datafile '_amicaout_asrinit'], opts.preproc_amicaout);
    

    
    %% Remove set files
    logging_log('INFO', 'Removing set files ifset');
    remove_ifset(preproc, [datafile '_concat_data.set'], opts.preproc_concat_data);
    remove_ifset(preproc, [datafile '_concat_asrdata.set'], opts.preproc_concat_asr);
    remove_ifset(preproc, [datafile '_sa.set'], opts.preproc_sa);
    remove_ifset(preproc, [datafile '_sa_purge.set'], opts.preproc_sa_purge);
    remove_ifset(preproc, [datafile '_asr.set'], opts.preproc_asr);
    remove_ifset(preproc, [datafile '_asr_purge.set'], opts.preproc_asr_purge);
    remove_ifset(preproc, [datafile '_compart_data.set'], opts.preproc_compart_data);
    remove_ifset(preproc, [datafile '_compart_data_purge.set'], opts.preproc_compart_data_purge);
    remove_ifset(preproc, [datafile '_preproc_dip.set'], opts.preproc_dip);
    
    %% Clean and zip
    
    clean_root_ifset(opts.trash_root);
    archive_logs(opts.zip_successful_logs, datafile, mfilename, ...
        logs_dir, opts.use_system_gzip, opts.use_system_xz, opts.use_zip)
    delete_logs(opts.delete_successful_logs, datafile, mfilename, logs_dir);
    
    if exist('confirm_recursive_rmdir', 'builtin')
        confirm_recursive_rmdir(pval);
    end
    logging_log('INFO', ['Completed pipeline_clean for ' datafile]);
end


function out = list_logs(datafile, mfilename, logs_dir)
    direxpr = ['(\w+)' '-' logs_dir];
    logpath = fullfile('analysis', 'log');
    dirinfo = dir(logpath);
    [match, tokens] = regexp({dirinfo.name}, direxpr, 'match', 'tokens');
    
    out = {};
    
    % Find logs/mfile for each dir
    for i=1:numel(tokens)
        if isempty(tokens{i})
            continue;
        end
        % Used for output file name
        tok = tokens{i}{1};
        % Name of dir in analysis/log
        mat = match{i}{1};
        rundir = fullfile(logpath, mat);
        rundinfo = dir(rundir);
        exp = [mfilename '.*'];
        runmatch = regexp({rundinfo.name}, exp, 'match');
        
        matches = runmatch(~cellfun(@isempty, runmatch));
        matches = cellfun(@(x) fullfile(rundir, x), matches, 'UniformOutput', false);
        matches = cellfun(@(x) struct('file', x, 'stage', tok), matches, 'UniformOutput', false);
        out = [out, matches];
    end
end

function archive_logs(isset, datafile, mfilename, logs_dir, strat_gzip, strat_xz, strat_zip)
    if ~isset
        return;
    elseif nargin ~= 7
        error('must use exactly 7 positional parameters');
    elseif sum([strat_gzip, strat_xz, strat_zip]) ~= 1
        error('Only one strategy can be picked for archiving logs');
    end
    
    out = list_logs(datafile, mfilename, logs_dir);
    
    tmpdirn = tempname();
    [~] = mkdir(tmpdirn);
    % TODO(brad) test this
    parttemp = fullfile(tmpdirn, datafile);
    mkdir(parttemp);
    
    for i=1:numel(out)
        [~, bn, ext] = fileparts(out{i}.file);
        % I prefer -'s
        targfile = fullfile(parttemp, [out{i}.stage '-' bn ext]);
        copyfile(out{i}.file, targfile);
    end
    [basedir, tdir, ~] = fileparts(parttemp);
    logpath = fullfile(pwd, 'analysis', 'log', [datafile '-' logs_dir]);
    % TODO(brad) test system for failures
    if strat_gzip
        system(sprintf('cd %s && tar --gzip -cf %s %s', basedir, [logpath '.tar.gz'], tdir));
    elseif strat_xz
        system(sprintf('cd %s && tar --xz -cf %s %s', basedir, [logpath '.tar.xz'], tdir));
    elseif strat_zip
        zip(logpath, parttemp, basedir);
    end
end



function delete_logs(isset, datafile, mfilename, logs_dir)
    if ~isset
        return;
    elseif nargin ~= 4
        error('must use exactly 4 positional parameters');
    end
    
    out = list_logs(datafile, mfilename, logs_dir);
    for i=1:numel(out)
        filen = out{1}.file;
        delete(filen);
    end
    [basedir, ~, ~] = fileparts(filen);
    dirinfo = dir(basedir);
    if numel(dirinfo) == 1 
        [~, name, ext] = fileparts(dirinfo(1).name);
        strcmp([name, ext], 'submit.sh')
        delete(dirinfo(1).name);
        rmdir(basedir);
    end
end

% Wrapper to check that pipeline was successful before cleanup
% function b = pipeline_success(datafile, mfilename, logs_dir)
function b = pipeline_success(datafile, ~, ~)
    b = exist(fullfile('analysis', 'data', '2_preproc', [datafile '_dip.set']), 'file');
end

function clean_root_ifset(b)
    % As we discover more files that can be 
    % cleaned up they should be added here
    if ~b
        return;
    end
    lock = try_lock_warn();
    if isempty(lock)
        logging_log('WARN', 'Another process had a lock, skipping this stage');
        return;
    end
    
    dirinfo = dir('.');
    remove_files_matching_regex(dirinfo, 'core\..+');
    remove_files_matching_regex(dirinfo, 'output.+');
    
    delete(lock);
end

function remove_files_matching_regex(dirinfo, expression, dry)
    index = regexp({dirinfo.name}, expression);
    for i=1:numel(index)
        if isempty(index{i})
            continue;
        end
        logging_log('INFO', ['Deleting ' dirinfo(i).name]);
        % Dry run
        if nargin > 2 && dry
            continue;
        end
        if dirinfo(i).isdir
            rmdir(dirinfo(i).name);
        else
            delete(dirinfo(i).name);
        end
        
    end
end

% Remove fdir/ffile if b is true, if we remove .set remove .fdt as well
% Prints a warning if the file doesn't exist
function remove_ifset(fdir, ffile, b)
    if ~b
        return;
    end
    ffpath = fullfile(fdir, ffile);
    if ~exist(ffpath, 'file')
        logging_log('DEBUG', sprintf(['expected file %s did not exist,' ...
            ' if you did not expect it to exist ignore this warning'], ...
            ffpath));
        return;
    end
    delete(ffpath);
    [p, n, ext] = fileparts(ffpath);
    if strcmp(ext, '.set')
        remove_ifset(p, [n '.fdt'], b)
    end
end

function remove_dir_ifset(fdir, ffile, b)
    if ~b
        return;
    end
    ffpath = fullfile(fdir, ffile);
    if ~exist(ffpath, 'dir')
        logging_log('DEBUG', sprintf(['expected file %s did not exist,' ...
            'if you did not expect it to exist ignore this warning'], ...
            ffpath));
        return;
    end
    rmdir(ffpath);
end

function sa = merge_struct(sa, sb)
    sbfieldnames = fieldnames(sb);
    for i=1:numel(sbfieldnames)
        sa.(sbfieldnames{i}) = sb.(sbfieldnames{i});
    end
end