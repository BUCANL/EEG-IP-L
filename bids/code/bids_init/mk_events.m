function events=mk_events(fname)

EEG = pop_loadset('filename',fname);

events={'onset','duration','trial_type'};%response_time,stim_file,...

for i=1:length(EEG.event);
   events{i+1,1}=EEG.event(i).latency*(1/EEG.srate); 
   events{i+1,2}=EEG.event(i).duration*(1/EEG.srate); 
   events{i+1,3}=EEG.event(i).type; 
end
