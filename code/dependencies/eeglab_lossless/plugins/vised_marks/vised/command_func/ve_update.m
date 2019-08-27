function EEG = ve_update(EEG)

udf = get(gcbf, 'userdata');

if isfield(udf, 'urdata');
    EEG.data = get(findobj('tag', 'eegaxis', 'parent', gcbf), 'userdata');
end

if isfield(udf, 'eventupdate');
    for i = 1:length(udf.eventupdate);
        switch udf.eventupdate(i).proc
            case 'new'
                eventindex = length(EEG.event) + 1;
                EEG.event(eventindex).latency = udf.eventupdate(i).latency;
                EEG.event(eventindex).type = udf.eventupdate(i).type;
                EEG.event(eventindex).duration = [];
                EEG.event(eventindex).channel = [];
                EEG.event(eventindex).bvtime = [];
                EEG.event(eventindex).bvmknum = [];
                EEG.event(eventindex).code = [];
                EEG.event(eventindex).urevent = [];
                if ndims(EEG.data) == 3;
                    EEG.event(eventindex).epoch = udf.eventupdate(i).epoch;
                end
            case 'clear'
                eventindex = udf.eventupdate(i).index;
                EEG.event(eventindex).action = 'clear';
        end
    end
end

j = 0;
for i = 1:length(EEG.event);
    if isfield(EEG.event(i), 'action') && strcmp(EEG.event(i).action, 'clear');
        j = j + 1;
        clearInd(j) = i;
    end
end

if isfield(EEG.event, 'action');
    EEG.event = rmfield(EEG.event, 'action');
end
if isfield(EEG.event, 'actlat');
    EEG.event = rmfield(EEG.event, 'actlat');
end

if exist('clearInd', 'var');
    EEG.event(clearInd) = [];
end

EEG = eeg_checkset(EEG, 'eventconsistency');

% ve_edit maintains original and does everything for us.
EEG.marks.time_info = udf.time_marks_struct;

% % Iterate through each marking type
% for i=1:length(EEG.marks.time_info)
%     % Read from the initial udf struct and multiply the scaling val and
%     % store in EEG structure as intermediate
%     EEG.marks.time_info(i).flags = udf.time_marks_struct(i).flags * udf.scalingVal(i);
%     % Read from EEG struct and add the minimum back in and assign to EEG.
%     EEG.marks.time_info(i).flags = EEG.marks.time_info(i).flags + udf.scalingMin(i);
% end
    
disp('wat');

%% HANDLE MANUAL SELECTION OF CHANNELS. UPDATE "manual" chan_info...
target_mark = '';
switch udf.data_type
    case 'EEG'
        target_mark = 'chan_info';
    case 'ICA'
        target_mark = 'comp_info';
end
for udfl_i = 1:length(udf.chan_marks_struct)
    eegl_i = find(strcmp(udf.chan_marks_struct(udfl_i).label, ...
        {EEG.marks.(target_mark).label}));
    if isempty(eegl_i)
        EEG.marks = marks_add_label(EEG.marks, target_mark, ...
            {udf.chan_marks_struct(udfl_i).label, ...
            udf.chan_marks_struct(udfl_i).line_color, ...
            udf.chan_marks_struct(udfl_i).tag_color, ...
            udf.chan_marks_struct(udfl_i).order, ...
            zeros(EEG.nbchan, 1)});
        eegl_i = length(EEG.marks.(target_mark));
    end
    for i = 1:length(udf.eloc_file)
        EEG.marks.(target_mark)(eegl_i).flags(udf.eloc_file(i).index, 1) = ...
            udf.chan_marks_struct(udfl_i).flags(i, 1);
    end
end

eeglab redraw

if isfield(udf, 'eloc_file') && length(udf.eloc_file(1).labels) >= 4 && ...
        strmatch(udf.eloc_file(1).labels(1:4), 'comp')
    datoric = 2;
end
if ~exist('datoric', 'var');
    datoric = 1;
end

if isfield(udf.eloc_file, 'badchan');
    switch datoric
        case 1
            for i = 1:length(udf.eloc_file);
                EEG.chanlocs(udf.eloc_file(i).index).badchan = udf.eloc_file(i).badchan;
            end
        case 2
            for i = 1:length(udf.eloc_file);
                EEG.reject.gcompreject(udf.eloc_file(i).index) = udf.eloc_file(i).badchan;
            end
    end
end

