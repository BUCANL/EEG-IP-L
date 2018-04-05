function EEG=reject2marks(EEG)

if ~isfield(EEG,'marks');
    if isempty(EEG.icaweights);
        EEG.marks=marks_init(size(EEG.data));
    else
        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));
    end
end

%CREATE MARKS.TIME_INFO INSTANCES FROM REJECT STRUCTURE FIELDS...
if ~isempty(find(EEG.reject.rejmanual));
    for i=1:EEG.trials;
        if EEG.reject.rejmanual(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejmanual',{EEG.marks.time_info.label}));
        disp('''rejmanual'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejmanual');
        %EEG=marks_removetype(EEG,'time_info','rejmanual');
    end
    EEG.marks = marks_add_label(EEG.marks,'time_info', ...
        {'rejmanual',EEG.reject.rejmanualcol,tmpflags});
end

if ~isempty(find(EEG.reject.rejthresh));
    for i=1:EEG.trials;
        if EEG.reject.rejthresh(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejthresh',{EEG.marks.time_info.label}));
        disp('''rejthresh'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejthresh');
        %EEG=marks_removetype(EEG,'time_info','rejthresh');
    end
    EEG.marks = marks_add_label(EEG.marks,'time_info', ...
        {'rejthresh',EEG.reject.rejthreshcol,tmpflags});
end

if ~isempty(find(EEG.reject.rejconst));
    for i=1:EEG.trials;
        if EEG.reject.rejconst(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejconst',{EEG.marks.time_info.label}));
        disp('''rejconst'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejconst');
        %EEG=marks_removetype(EEG,'time_info','rejconst');
    end
    EEG.marks=marks_add_label(EEG.marks,'time_info', ...
        {'rejconst',EEG.reject.rejconstcol,tmpflags});
end

if ~isempty(find(EEG.reject.rejjp));
    for i=1:EEG.trials;
        if EEG.reject.rejjp(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejjp',{EEG.marks.time_info.label}));
        disp('''rejjp'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejjp');
        %EEG=marks_removetype(EEG,'time_info','rejjp');
    end
    EEG.marks=marks_add_label(EEG.marks,'time_info', ...
        {'rejjp',EEG.reject.rejjpcol,tmpflags});
end

if ~isempty(find(EEG.reject.rejkurt));
    for i=1:EEG.trials;
        if EEG.reject.rejkurt(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejkurt',{EEG.marks.time_info.label}));
        disp('''rejkurt'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejkurt');
        %EEG=marks_removetype(EEG,'time_info','rejkurt');
    end
    EEG.marks=marks_add_label(EEG.marks,'time_info', ...
        {'rejkurt',EEG.reject.rejkurtcol,tmpflags});
end

if ~isempty(find(EEG.reject.rejfreq));
    for i=1:EEG.trials;
        if EEG.reject.rejfreq(i);
            tmpflags(1,:,i)=ones(1,EEG.pnts,1);
        else
            tmpflags(1,:,i)=zeros(1,EEG.pnts,1);
        end
    end
    if find(strcmp('rejfreq',{EEG.marks.time_info.label}));
        disp('''rejfreq'' mark type already exists... replacing it.');
        EEG.marks=pop_marks_add_label(EEG.marks,'action','remove','info_type','time_info','label','rejfreq');
        %EEG=marks_removetype(EEG,'time_info','rejfreq');
    end
    EEG.marks=marks_add_label(EEG.marks,'time_info', ...
        {'rejfreq',EEG.reject.rejfreqcol,tmpflags});
end
