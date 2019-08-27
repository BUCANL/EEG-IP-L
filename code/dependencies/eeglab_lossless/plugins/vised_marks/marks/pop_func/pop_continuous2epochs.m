function [EEG,com]=pop_continuous2epochs(EEG,varargin)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_continuous2epochs;
	return;
end;	



% pop up window
% -------------
if nargin < 2

    results=inputgui( ...
    {[4 2] [4 2] [6] [4 2] [4 2]}, ...
    {...
        {'Style', 'text', 'string', 'Epoch recurrence interval in seconds (default 1).'}, ...
        {'Style', 'edit', 'tag', 'edt_rec'}, ...
        {'Style', 'text', 'string', 'time limits of epochs around recurrence in seconds (default [0 1]).'}, ...
        {'Style', 'edit', 'tag', 'edt_lim'}, ...
        {'Style', 'checkbox', 'string', 'Keep boundary events in the epochs when they occur', ...
        'value',1}, ...
        {'Style', 'text', 'string', 'Remove baseline from epochs'}, ...
        {'Style', 'edit', 'tag', 'edt_rmbase','string',''}, ...
        {'Style', 'text', 'string', 'Label for temporary epoching event.'}, ...
        {'Style', 'edit', 'tag', 'edt_lim','string','tmp_cnt2win'}, ...
    }, ...
    'pophelp(''pop_continuous2epochs'');', 'convert data from continuous to epochs -- pop_continuous2epochs()' ...
    );

    if isempty(results);return;end
    recurrence  	 = results{1};
    limits      	 = results{2}; 
    keep_boundaries  = results{3};
    rm_baseline      = results{4};
    evt_label        = results{5};
end

options='';

if ~isempty(recurrence);
    options=[options,',''recurrence'',', recurrence];
end

if ~isempty(limits);
    options=[options,',''limits'',[', limits,']'];
end

if ~isempty(keep_boundaries);
    if keep_boundaries==1;
        options=[options,',''keepboundary'',''on'''];
    else
        options=[options,',''keepboundary'',''off'''];
    end
end

if ~isempty(rm_baseline);
    options=[options,',''rmbase'',[', rm_baseline,']'];
end

if ~isempty(evt_label);
    options=[options,',''eventtype'',''', evt_label,''''];
end

% create the string command
% -------------------------
com = ['EEG = pop_continuous2epochs(EEG',options,');'];
exec_com = ['EEG = marks_continuous2epochs(EEG',options,');'];
eval(exec_com)