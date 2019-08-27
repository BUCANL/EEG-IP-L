% pop_runhtb() - populate and show a GUI for editing batch processing parameters 
% and run history scripts on multiple input files with parameters specified in 
% the batch_config and context_config structures found in the workspace.
%
% Usage:
%   >>  pop_runhtb(htb_fname,htb_fpath,input_fname,input_fpath);
%
% Inputs:
%   htb_fname       - Name(s) of history template file(s).
%   htb_fpath       - Path of history template file(s).
%   input_fname     - Name(s) of input file(s).
%   input_fpath     - Path of batch file(s)
%    
% Outputs:
%   Although not stated in the call, this function creates the job_struct
%   structure that is pased to subsequent functions that executes the batch 
%   pipelines. The job_struct structure contains all of the information 
%   (combined from htb_fname, input_fname, batch_config and context_config) 
%   that is required to execute a batch pipeline. 
%
% See also:
%   pop_savehtb(), pop_batch_edit(), pop_context_edit() 
%

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, Andrew Lofts,
%                 and Mae Kennedy
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

function pop_runhtb(htb_fname, htb_fpath, input_fname, input_fpath)

% Get cell array of base workspace variables. It would be cleaner and scale
% easier if evalins output was a structure. But for now, parsing the cell
% array leads to less immediate changes to the code.
try 
    parameters = evalin('base', 'batch_config');
    batch_config = parameters;
catch %if nonexistent in workspace
    batch_config = init_batch_config;
end
    
try 
    parameters = evalin('base', 'context_config');
    context_config = parameters;
catch %if nonexistent in workspace
    context_config = init_context_config;
end

rsub_meth_cell = {'system', 'ssh2', 'none'};

%% HANDLE batch_config...
PropGridStr_batchconfig = ...
    ['global bcp;' ...
    'batch_config = evalin(''caller'', ''batch_config'');' ... 
    'properties=batchconfig2propgrid(batch_config);' ...
    'properties = properties.GetHierarchy();' ...
    'bcp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.046 .42 .48 .395]);' ...
    ];

%% HANDLE context_config...
PropGridStr_contextconfig = ...
    ['global ccp;' ...
    'context_config = evalin(''caller'', ''context_config'');' ... 
    'properties=contextconfig2propgrid(context_config);' ...
    'properties = properties.GetHierarchy();' ...
    'ccp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.046 .087 .912 .298]);' ...
    ];

%% POP_RUNHTB GUI...
% pop up window
% -------------
if nargin < 4
    
    results=inputgui( ...
        'geom', ...
        {...
        {8 26 [0 0] [1 1]} ... %1 blanks.
        {8 26 [0.05 -1] [1.8 1]} ... %2 history file push button
        {8 26 [0.05 -.2] [4.3 1]} ... %3 history path edit box
        {8 26 [0.05 .6] [4.3 2.5]} ... %4 history file edit box
        {8 26 [4.7 -1] [1.8 1]} ... %5 data file push button
        {8 26 [6.32 -1] [1.68 1]} ... %5.1 bids file push button
        {8 26 [4.22 -.2] [1 1]} ... %6 path: text
        {8 26 [4.7 -.2] [3.3 1]} ... %7 data path edit box
        {8 26 [4.32 .6] [1 1]} ... %8 file: text
        {8 26 [4.7 .6] [3.3 16]} ... %9 data file edit box
        {8 26 [0.05 3] [1.8 1]} ... %10 batch config push button
        {8 26 [0.05 16.5] [1.8 1]} ... %11 batch config push button
        {8 26 [0.05 27.3] [2 1]} ...
        {8 26 [1.8 26.9] [1.36 1]} ...
        
        }, ...
        'uilist', ...
        {...
        {'Style', 'text', 'string', blanks(16)} ... %1 This is just for a blank string of a given length to set the width of the GUI.
        {'Style', 'pushbutton', 'string', 'History file', ...
        'callback', ...
        ['path = ''*.htb'';' ...
        'if exist(''context_config'', ''var''); path = [find_hints_context_config(context_config, ''scripts_dir'') path]; end;' ...
        '[htb_fname, htb_fpath] = uigetfile(''*.htb'',''Select History Template Batch file:'',' ... 
        'path,''multiselect'',''on'');', ...
        'if isnumeric(htb_fname);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_hfp''),''string'',htb_fpath);', ...
        'set(findobj(gcbf,''tag'',''edt_hfn''),''string'',htb_fname);']} ... %2 history file push button
        {'Style', 'edit', 'tag', 'edt_hfp'} ... %3 history path edit box
        {'Style', 'edit', 'max', 500, 'tag', 'edt_hfn'} ... %4 history file edit box
        {'Style', 'pushbutton', 'string', 'Data file import', ...
        'callback', ...
        ['path = ''*.*'';' ...
        'if exist(''context_config'', ''var''); path = [find_hints_context_config(context_config, ''data_dir'') path]; end;' ...
        '[input_fname, input_fpath] = uigetfile(''*.*'',''Select data files or ESS metadata XML file:'',' ...
        'path, ''multiselect'',''on'');', ...
        'if isnumeric(input_fname);return;end;', ...
        'set(findobj(gcbf,''tag'',''edt_dfp''),''string'',input_fpath);', ...
        'set(findobj(gcbf,''tag'',''lst_dfn''),''string'',input_fname);']} ... %5 data file push button
        {'Style', 'pushbutton', 'string', 'BIDS import', ...
        'callback', ...
        ['rootF = uigetdir();',...
         '[exitCode, projRoot] = system(''pwd'');',...
         'fNames = pop_rfind(projRoot,rootF);', ... % call to recursive crawl method
         'set(findobj(gcbf,''tag'',''lst_dfn''),''string'',deblank(fNames));']} ... %5 data file push button
        {'Style', 'text', 'string', 'path:'} ... %6 path: text
        {'Style', 'edit', 'tag','edt_dfp'} ... %7 data path edit box
        {'Style', 'text', 'string', 'file:'} ... %8 file: text
        {'Style', 'edit', 'max', 500, 'tag', 'lst_dfn'} ... %9 data file edit box
        {'Style', 'pushbutton','string','Load batch config', ...
        'callback', ...
        ['pop_loadbatchconfig();', ...
        'global bcp;' ...
        'batch_config = evalin(''base'', ''batch_config'');' ...
        'properties=batchconfig2propgrid(batch_config);' ...
        'properties = properties.GetHierarchy();' ...
        'bcp = PropertyGrid(gcf,' ...
        '''Properties'', properties,' ...
        '''Position'', [.046 .42 .48 .395]);']} ... %10 batch config push button
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
        '''Position'', [.046 .087 .912 .298]);']} ... %11 context config push button
        {'Style', 'text', 'string', 'Remote submit communication method'} ...
        {'Style', 'popup', 'string', rsub_meth_cell} ...
        }, ...
        'title', 'Select batching parameters -- pop_runhtb()', ...
        'eval', [PropGridStr_batchconfig PropGridStr_contextconfig] ...
        );
    
    if isempty(results) 
        return;
    end
    
    % bring back current state of base structures
    try 
        parameters = evalin('base', 'batch_config');
        batch_config = parameters;
    catch %if nonexistent in workspace
        batch_config = init_batch_config;
    end
    
    global bcp;
    batch_config = propgrid2batchconfig(bcp, batch_config);
    clear global bcp
    assignin('base', 'batch_config', batch_config);

  
    global ccp;
    context_config = propgrid2contextconfig(ccp);
    clear global ccp
    assignin('base', 'context_config', context_config);
    
    htb_fpath = results{1};
    htb_fname = results{2};
    input_fpath = results{3};
    input_fname = results{4};
    rsub_meth = rsub_meth_cell{results{5}};
end

%% HANDLE REQUIRED INPUTS...
% check that required files have been specified...
if isempty(htb_fname)
    disp('No history template files have been specified');
    disp('Quitting batch procedure...');
    return
end
if isempty(input_fname);
    disp('No input data files have been specified');
    disp('Quitting batch procedure...');
    return
end

% if a single history file is chosen convert the htb_fname string into a cell array...
if ischar(htb_fname)
    htb_fname=cellstr(htb_fname);
end

% ESS Capsule Loading
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if a single input data file is chosen convert the input_fname string into a cell array...
if ischar(input_fname)
    input_fname=cellstr(input_fname);
    
% Load Capsule
if all(input_fname{1}(end-3:end) == '.xml')
    
    % Load Level 2 Capsule
    disp('Checking Level of ESS...');
    if any(strfind(input_fname{1},'Level2')) || any(strfind(input_fname{1},'level2')) ...
            || any(strfind(input_fname{1},'Level_2')) || any(strfind(input_fname{1},'level_2'))
    % load the container in to a MATLAB object
    % Looking For any of these in the file name
    % Level2, level2, Level_2, level_2
        obj = level2Study('level2XmlFilePath', input_fpath);
        disp('Level 2 Loaded');
        % get all the recording files 
        filenames = obj.getFilename;
        for i = 1:length(obj.studyLevel2Files.studyLevel2File)
            filenames{i} = obj.studyLevel2Files.studyLevel2File(i).studyLevel2FileName;
            disp([filenames{i} ' was found']);
        end
        
    % Load Level 1 Capsule
    else
        obj = level2Study('level1XmlFilePath', input_fpath);
        disp('Level 1 Loaded');    
        % get all the recording files 
        filenames = obj.getFilename;
        for i = 1:length(obj.level1StudyObj.sessionTaskInfo)
            filenames{i} = obj.level1StudyObj.sessionTaskInfo(i).dataRecording(1).filename;
            disp([filenames{i} ' was found']);
        end
        warning('Please check the ESS compatibility with Batching');
    end 
    
    input_fname = filenames';
end

end %End of solo file selected if statement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% START BATCHING PROCEDURE...

starttime = datestr(now, 'yyyy-mm-ddTHH-MM-SS');
password_sshfm = '';
for hi=1:length(htb_fname)
    %% DO FOR EACH HISTORY FILES FILE...
    
    %the first index is the order the rest are waits
    %current base does not care about order
    ordercode = batch_config(hi).order;
    
    % Get all valid exec functions
    vnames = get_valid_exec_func();
    % Remove current base
    vnames = vnames(~strcmp('ef_current_base', vnames));
    if strcmp('ef_current_base', batch_config(hi).exec_func)
        disp('Executing local scripts in a linear order');
    elseif any(strcmp(vnames,  batch_config(hi).exec_func))
        % If no order is given then make the batches consectutive
        if (isempty(ordercode))     
            disp(['No order was specified! - Executing ' ...
                'remote scripts in a linear order']);
            if (hi == 1)
                ordercode = hi;
            else
                ordercode = [hi, hi-1];
            end
        end
        ordernum = (ordercode(1));
        waitnum = (ordercode(2:end));
        job_struct(hi).waitnum = waitnum;
        job_struct(hi).ordernum = ordernum;
    else
        error(['unknown exec_func, please open a ticket if you' ...
            ' require %s support'], batch_config(hi).exec_func);
    end
    
    job_struct(hi).batch_config = batch_config(hi);
    job_struct(hi).context_config = context_config;
    job_struct(hi).submeth = rsub_meth;
    job_struct(hi).batch_dfn = input_fname;
    job_struct(hi).batch_dfp = input_fpath;
    job_struct(hi).batch_hfn = htb_fname{hi};
    job_struct(hi).batch_hfp = htb_fpath;
    job_struct(hi).m_path = '';
    job_struct(hi).starttime = starttime;
    job_struct(hi).exec_str = {''};
    if strcmp(batch_config(hi).exec_func,'ef_current_base')
    	job_struct = ef_current_base(job_struct);
    else
        % Get a handle for our exec function
        handle = eval(['@', batch_config(hi).exec_func '_driver']);
        driver = handle();
        job_struct = make_job_dir(driver, job_struct);

        %% EXECUTE/SUBMIT JOBS...
        % try: Matlab 2015 includes libcrypto.so which messes with the
        % ssh on the system as it is included in the LD_LIBRARY_PATH on 
        % startup. We, therefore, remove it and restore afterwards however
        % if an error occurs we still want to restore it. Note: If you need
        % LD_LIBRARY_PATH here please open a ticket and we will make this
        % more specific
        try 
            ld_library_path_store = getenv('LD_LIBRARY_PATH');
            setenv('LD_LIBRARY_PATH', '');
            switch rsub_meth
                case 'system'
                    job_struct = rsub_sys(job_struct, driver);

                case 'ssh2'
                    disp('submitting jobs using sshfrommatlab...')
                    if isempty(password_sshfm)
                        password_sshfm = passwordEntryDialog(...
                            'CheckPasswordLength', false, ...
                            'WindowName', ...
                            sprintf('Password for %s on %s', ...
                            context_config.remote_user_name, ...
                            context_config.remote_exec_host));
                    end
                    sshfm_opts.password = password_sshfm;
                    job_struct = rsub_sys(job_struct, driver, sshfm_opts);
                case 'none'
                    disp('The job files are generated ... finished.');
            end
        catch err
            setenv('LD_LIBRARY_PATH', ld_library_path_store);
            rethrow(err);
        end
        ld_library_path_store = getenv('LD_LIBRARY_PATH');
    end
end
    
    

