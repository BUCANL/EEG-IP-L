function eeg_init(EEG,infname)

disp(['current file: ', infname(1:end-1)])

%parse infname.
[p,n]=fileparts(infname);
%subject ID
subids_ind=strfind(lower(n),'ec_t')+6;
subide_ind=strfind(lower(n),'ec_t')+8;
subid=n(subids_ind:subide_ind);

if isempty(str2num(subid));
    ecs_ind=strfind(lower(n),'ec');
    if strcmp(lower(n(ecs_ind+7)),'t');
        subid=n(ecs_ind+3:ecs_ind+5);
    elseif strcmp(lower(n(ecs_ind+6)),'t');
        subid=n(ecs_ind+2:ecs_ind+4);
    elseif strcmp(lower(n(ecs_ind+3)),'p');
        subid=n(ecs_ind+5:ecs_ind+7);
    end
    
    if isempty(str2num(subid));
        disp('COULD NOT FIND THE SUBJECT ID.');
        return;
    end
end

%session ID 
sesids_ind=strfind(n,'_t')+2;
sesid=n(sesids_ind);

if isempty(str2num(sesid));
    disp('COULD NOT FIND THE SESSION ID.');
    return;
end

if strcmp(sesid,'1');
    agelab='m06';
    tasklab='t1task';
elseif strcmp(sesid,'2');
    agelab='m12';
    tasklab='t2task';
elseif strcmp(sesid,'3');
    agelab='m18';
    tasklab='t3task';
end

outfpath=['sub-s',subid,'/ses-',agelab,'/eeg/'];
disp(['outpath: ', outfpath]);
disp(['current session: ' sesid]);

    
EEG = pop_readegi(infname(1:end-1), [],[],'auto');

%ADD Cz TO DATA ARRAY.
EEG.data(129,:)=zeros(size(EEG.data(1,:)));
EEG.nbchan=129;
EEG.chanlocs(129)=EEG.chanlocs(128);
EEG.chanlocs(129).labels=EEG.chaninfo.nodatchans(4).labels;
EEG.chanlocs(129).Y=EEG.chaninfo.nodatchans(4).Y;
EEG.chanlocs(129).X=EEG.chaninfo.nodatchans(4).X;
EEG.chanlocs(129).Z=EEG.chaninfo.nodatchans(4).Z;
EEG.chanlocs(129).sph_theta=EEG.chaninfo.nodatchans(4).sph_theta;
EEG.chanlocs(129).sph_phi=EEG.chaninfo.nodatchans(4).sph_phi;
EEG.chanlocs(129).sph_radius=EEG.chaninfo.nodatchans(4).sph_radius;
EEG.chanlocs(129).theta=EEG.chaninfo.nodatchans(4).theta;
EEG.chanlocs(129).radius=EEG.chaninfo.nodatchans(4).radius;
EEG.chanlocs(129).type='EEG';
EEG.chaninfo.nodatchans=EEG.chaninfo.nodatchans(1:3);

EEG = pop_chanedit(EEG, 'load',{'sourcedata/misc/GSN129.sfp' 'filetype' 'autodetect'});

if ~isempty(EEG.event);
    for i=1:length(EEG.event);
        if strcmp(EEG.event(i).type,'epoc');
            EEG.event(i).type='boundary';
        end
    end
end

% CHECK FOR OUTPUT PATH AND CRETAE IF NECESSARY
if ~exist(outfpath);
    disp(['Making directory ', outfpath]);
    eval(['mkdir ' outfpath]);
end

outfname=['sub-s',subid,'_ses-',agelab,'_task-',tasklab,'_eeg.set'];

if strcmp(n(1:2),'p0');
    outfname = ['sub-s',subid,'_ses-',agelab,'_task-',tasklab,'_eeg_',n(1:3),'.set'];
end

if strcmp(n(end-5:end-3),'eeg');
    outfname = ['sub-s',subid,'_ses-',agelab,'_task-',tasklab,'_eeg_p',n(end-1:end),'.set'];
end

disp(outfname);

%save output set file
EEG = pop_saveset( EEG, 'filename',[outfpath,'/',outfname]);
end
