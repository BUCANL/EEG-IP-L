% movetype  1=append marks structure to the data array.
%           2=take appended marks from data array back to marks structure.

function EEG=marks_moveflags(EEG,movetype)

switch movetype
    
    case 1
        if ~isfield(EEG,'marks')
            if isempty(EEG.icaweights);
                EEG.marks=marks_init(size(EEG.data));
            else
                EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));
            end
        end
        
        for i=1:length(EEG.marks.time_info)
            disp(['Appending ''',EEG.marks.time_info(i).label, ''' flags to data array...']);
            EEG.nbchan=EEG.nbchan+1;
            EEG.data(EEG.nbchan,:,:)=EEG.marks.time_info(i).flags;
            EEG.chanlocs(EEG.nbchan).labels=EEG.marks.time_info(i).label;
        end
        
%        for i=1:length(EEG.marks.chan_info)
%            disp(['Appending ''',EEG.marks.chan_info(i).label, ''' flags to data array...']);
%            EEG.pnts=EEG.pnts+1;
%            EEG.data(:,EEG.pnts,:)=EEG.marks.chan_info(i).flags;
%        end
        
%        ncomp=min(size(EEG.icaweights));
%        for i=1:length(EEG.marks.comp_info)
%            disp(['Appending ''',EEG.marks.comp_info(i).label, ''' flags to data array...']);
%            EEG.pnts=EEG.pnts+1;
%            EEG.data(:,EEG.pnts,:)=EEG.marks.chan_info(i).flags;
%            EEG.chanlocs(EEG.pnts).labels=EEG.marks.chan_info(i).label;
%        end
        
    case 2
        if ~isfield(EEG,'marks')
            EEG=marks_init(EEG);
        end
        
        for i=1:length(EEG.marks.time_info)
            cmarklabel=EEG.marks.time_info(i).label;
            disp(['Moving ''',cmarklabel, ''' flags from data array...']);
            chind(i)=strmatch(cmarklabel,{EEG.chanlocs.labels},'exact');
            EEG.marks.time_info(i).flags=EEG.data(chind(i),:,:);
        end
        
        EEG=pop_select(EEG,'nochannel',chind);

end
