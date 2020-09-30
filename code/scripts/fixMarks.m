lossless_marks = load('derivatives/BIDS-Lossless-EEG/code/scripts/lossless_marks.mat');

timeOrdering = {'manual','init_ind','ch_sd','low_r','mark_gap','logl_init', ...
    'ic_sd1','logl_A','logl_B','logl_C','ic_sd2','ic_dt','ic_a','ic_b','ic_lg','ic_hg'};

for mark=1:length(lossless_marks.extra.chan_info)
    id = 0;
    for i=1:length(EEG.marks.chan_info)
        if(strcmp(EEG.marks.chan_info(i).label,lossless_marks.extra.chan_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.chan_info(id).line_color = lossless_marks.extra.chan_info(mark).line_color;
    	EEG.marks.chan_info(id).tag_color = lossless_marks.extra.chan_info(mark).tag_color;
        EEG.marks.chan_info(id).order = lossless_marks.extra.chan_info(mark).order;
    end
end

for mark=1:length(lossless_marks.extra.comp_info)
    id = 0;
    for i=1:length(EEG.marks.comp_info)
        if(strcmp(EEG.marks.comp_info(i).label,lossless_marks.extra.comp_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.comp_info(id).line_color = lossless_marks.extra.comp_info(mark).line_color;
        EEG.marks.comp_info(id).tag_color = lossless_marks.extra.comp_info(mark).tag_color;
        EEG.marks.comp_info(id).order = lossless_marks.extra.comp_info(mark).order;
    end
end

for mark=1:length(lossless_marks.extra.time_info)
    id = 0;
    for i=1:length(EEG.marks.time_info)
        if(strcmp(EEG.marks.time_info(i).label,lossless_marks.extra.time_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.time_info(id).color = lossless_marks.extra.time_info(mark).color;
    end
end

% Find which marks need to go after manual and init_ind and leave them
% alone for now
currentOrder = {EEG.marks.time_info.label};
[inter,ia,ib] = intersect(currentOrder,timeOrdering, 'stable');
extraMarks = currentOrder;
extraMarks(ia) = [];
% Build a new marks structure that is sorted according to timeOrdering
for i=1:length(timeOrdering)
    indexC = strfind(currentOrder,timeOrdering{i});
    index = find(not(cellfun('isempty',indexC)));
    
    EEG.marks.sorted_info(i) = EEG.marks.time_info(index);
end

% Append extra marks to additonal mark structure
for i=1:length(extraMarks)
    indexC = strfind(currentOrder,extraMarks{i});
    index = find(not(cellfun('isempty',indexC)));
    
    EEG.marks.extra_info(i) = EEG.marks.time_info(index);
end

% Rebuild based on sorted information and known order
% These will always be the first two...
EEG.marks.time_info(1) = EEG.marks.sorted_info(1);
EEG.marks.time_info(2) = EEG.marks.sorted_info(2);
try
    extraLen = length(EEG.marks.extra_info);
catch ME,
    extraLen = 0;
end
if extraLen > 0
    for i=1:extraLen
        EEG.marks.time_info(2+i) = EEG.marks.extra_info(i);
    end
    EEG.marks = rmfield(EEG.marks,'extra_info');
end
for i=3:length(EEG.marks.sorted_info)
    EEG.marks.time_info(extraLen+i) = EEG.marks.sorted_info(i);
end
EEG.marks = rmfield(EEG.marks,'sorted_info');