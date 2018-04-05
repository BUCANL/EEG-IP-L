function EEG=marks_epochs2continuous(EEG)

evtcount=0;
if ~isempty(EEG.event); % in case there are no events
tmp.event=EEG.event;
EEG.event=tmp.event(1);
%rejints=[];
end

sampdur=(1000/EEG.srate);%duration of each sample...
relstrtt=EEG.xmin*1000;%relative (to lock event) start time of current window...

%size(EEG.data)
%check that marks flag size is consistent with the data array...
if isfield(EEG,'marks')
    if size(EEG.data(1,:,:),3)~=size(EEG.marks.time_info(1).flags,3);
        disp('Marks structure is not consistent with the data dimensions... clearing marks structure...');
        EEG=rmfield(EEG,'marks');
    end
end

%collect reject structure into the marks structure...
EEG=reject2marks(EEG);

%size(EEG.marks.time_info(1).flags)

%check for latency flag channels and get their indeces in the data
%array...
if isfield(EEG,'marks');
    EEG=marks_moveflags(EEG,1);
    for i=1:length(EEG.marks.time_info);
        time_info_ind(i)=strmatch(EEG.marks.time_info(i).label,{EEG.chanlocs.labels},'exact');
    end
end

%data=zeros(size(EEG.data,1),EEG.epoch(EEG.trials).startpnt+EEG.pnts-1);

%Concatenate the data...
tmp_pntgap=0;
pntgap=0;
lastevtpnt=0;
consecpnts_warn=0;
j=0;
bndlat=[];

disp(['concatenating ', num2str(EEG.trials), ' epochs...']);
data=zeros(EEG.nbchan,EEG.pnts*EEG.trials);
for epi=1:EEG.trials;
    %calculate the distance between the current window and the end
    %of the concatenated data...
    %bnddur=EEG.epoch(epi).startpnt-(size(data,2)+cbnddur);
    if epi>1;
        tmp_pntgap=EEG.epoch(epi).startpnt-(EEG.epoch(epi-1).startpnt+(EEG.pnts-1));
    else
        pntgap=EEG.epoch(epi).startpnt-1;
    end
    %if the new window overlaps the concatenated data...
    if tmp_pntgap<=1;
        if tmp_pntgap==1 && consecpnts_warn==0;
            disp('Warning! some epochs are consecutive (no boundary inserted.. also no overlapping points to correct voltages if necessary)')
            consecpnts_warn=1;
        end
        %find the voltage difference between overlapping points...
        if epi==1||tmp_pntgap==1;
            winbase=zeros(size(EEG.data(:,1)));
        else
            winbase=EEG.data(:,1,epi)-data(:,EEG.epoch(epi).startpnt-pntgap);
        end
        
        %for each channel append the new data window and correct
        %the voltage value...
        for chi=1:EEG.nbchan;
            if isempty(find(time_info_ind==chi));
                data(chi,EEG.epoch(epi).startpnt-pntgap:EEG.epoch(epi).startpnt-pntgap+(EEG.pnts-1))=EEG.data(chi,:,epi)-winbase(chi);
            else
                %if epi>1;
                %    data(chi,EEG.epoch(epi).startpnt-pntgap:EEG.epoch(epi).startpnt-pntgap+(EEG.pnts-1))=max([EEG.data(chi,1,epi),EEG.data(chi,1,epi-1)]);
                %else
                    data(chi,EEG.epoch(epi).startpnt-pntgap:EEG.epoch(epi).startpnt-pntgap+(EEG.pnts-1))=EEG.data(chi,:,epi);
                %end
            end
        end
        %if the new window does not overlap the concatenated data...
    else
        
        %log a new boundary event data point index...
        j=j+1;
        bndlat(j)=size(data,2)+.5;
        
        %add the current gap to the cumulative boundary variable...
        pntgap=pntgap+tmp_pntgap;
        
        %add the current window to the end of the concatenated
        %data...
        data(:,EEG.epoch(epi).startpnt-pntgap:EEG.epoch(epi).startpnt-pntgap+(EEG.pnts-1))=EEG.data(:,:,epi);
    end
    
    %handle events...
    if ischar(EEG.epoch(epi).eventtype);
        EEG.epoch(epi).eventtype=cellstr(EEG.epoch(epi).eventtype);
        EEG.epoch(epi).eventlatency={EEG.epoch(epi).eventlatency};
    end
    for evi=1:length(EEG.epoch(epi).eventtype);
        %adjust new EEG.event latency field...
        cntstrtpnt=(EEG.epoch(epi).startpnt-pntgap);%start point of current window in the new continuous data...
        evtept=abs(relstrtt-EEG.epoch(epi).eventlatency{evi});%event time within the current window...
        evteppnts=evtept/sampdur;
        clat=evteppnts+cntstrtpnt;
%        if epi<11;
%            epi
%            evi
%            clat
%            lastevtpnt
%            clat-lastevtpnt
%            EEG.epoch(epi).eventurevent{evi}
%            if evtcount>1;EEG.event(evtcount-1).urevent;end
%        end
        if evtcount==0;
            evtcount=evtcount+1;
            EEG.event(evtcount)=tmp.event(EEG.epoch(epi).event(evi));
            EEG.event(evtcount).latency=clat;
            EEG.event(evtcount).epoch=1;
        else
            if iscell(EEG.epoch(epi).eventurevent);
                eurevent=EEG.epoch(epi).eventurevent{evi};
            else
                eurevent=EEG.epoch(epi).eventurevent(evi);
            end
            
            if clat>lastevtpnt && EEG.event(evtcount).urevent~=eurevent;
                %add new event to EEG.event structure...
                evtcount=evtcount+1;
                EEG.event(evtcount)=tmp.event(EEG.epoch(epi).event(evi));
                EEG.event(evtcount).latency=clat;
                EEG.event(evtcount).epoch=1;
            end
        end
    end
    if evtcount>0;
        lastevtpnt=EEG.event(evtcount).latency;
    end
end
data=data(:,1:EEG.epoch(epi).startpnt-pntgap+(EEG.pnts-1));

for i=1:length(bndlat);
    EEG.event(length(EEG.event)+1).type='boundary';
    EEG.event(length(EEG.event)).latency=bndlat(i);
    EEG.event(length(EEG.event)).urevent=[];
    EEG.event(length(EEG.event)).duration=0;
    EEG.event(length(EEG.event)).epoch=1;
end

EEG.trials=1;
EEG.pnts=size(data,2);

EEG.data=[];
EEG.epoch=[];

EEG.data=data;
EEG.xmin=0;
EEG.xmax=(size(EEG.data,2)-1)*(1/EEG.srate);

if isfield(EEG,'marks');
    EEG=marks_moveflags(EEG,2);
end

EEG=eeg_checkset(EEG);
