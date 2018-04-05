function electrodes=mk_electrodes(fname)

EEG = pop_loadset('filename',fname);

electrodes={'name','x','y','z','type','material'};%description,sampling_frequency,low_cutoff,high_cutoff,notch,status

for i=1:length(EEG.chanlocs);
   electrodes{i+1,1}=EEG.chanlocs(i).labels; 
   electrodes{i+1,2}=EEG.chanlocs(i).X; 
   electrodes{i+1,3}=EEG.chanlocs(i).Y; 
   electrodes{i+1,4}=EEG.chanlocs(i).Z; 
   electrodes{i+1,5}='active/cap'; %this needs to be in a default file somewhere. 
   electrodes{i+1,6}='Ag/AgCl'; %this needs to be in a default file somewhere. 
end
