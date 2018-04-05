function channels=mk_channels(fname)

EEG = pop_loadset('filename',fname);

channels={'name','type'};%description,sampling_frequency,low_cutoff,high_cutoff,notch,status

if isfield(EEG,'marks');
    channels={channels{:},'manual'};
end
for i=1:length(EEG.chanlocs);
   channels{i+1,1}=EEG.chanlocs(i).labels; 
   if isempty(EEG.chanlocs(i).type);
       channels{i+1,2}='EEG';
   else 
       channels{i+1,2}=EEG.chanlocs(i).type;
   end
   if isfield(EEG,'marks');
      if EEG.marks.chan_info(1).flags(i);
         channels{i+1,3}='TRUE';
      else
          channels{i+1,3}='FALSE';
      end
   end
end
