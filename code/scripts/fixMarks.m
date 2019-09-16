for mark=1:length(lossless_marks.mat.chan_info)
    id = 0;
    for i=1:length(EEG.marks.chan_info)
        if(strcmp(EEG.marks.chan_info(i).label,lossless_marks.mat.chan_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.chan_info(id).line_color = lossless_marks.mat.chan_info(mark).line_color;
    	EEG.marks.chan_info(id).tag_color = lossless_marks.mat.chan_info(mark).tag_color;
        EEG.marks.chan_info(id).order = lossless_marks.mat.chan_info(mark).order;
    end
end

for mark=1:length(lossless_marks.mat.comp_info)
    id = 0;
    for i=1:length(EEG.marks.comp_info)
        if(strcmp(EEG.marks.comp_info(i).label,lossless_marks.mat.comp_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.comp_info(id).line_color = lossless_marks.mat.comp_info(mark).line_color;
        EEG.marks.comp_info(id).tag_color = lossless_marks.mat.comp_info(mark).tag_color;
        EEG.marks.comp_info(id).order = lossless_marks.mat.comp_info(mark).order;
    end
end

for mark=1:length(lossless_marks.mat.time_info)
    id = 0;
    for i=1:length(EEG.marks.time_info)
        if(strcmp(EEG.marks.time_info(i).label,lossless_marks.mat.time_info(mark).label))
            id = i;
        end
    end
    if id
        EEG.marks.time_info(id).color = lossless_marks.mat.time_info(mark).color;
    end
end