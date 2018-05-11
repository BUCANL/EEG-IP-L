function init_bids_sub(EEG,rootfname,fnamesuf)

sidecar_eeg=mk_sidecar_eeg(EEG,[rootfname,'_',fnamesuf,'.set']);
savejson('',sidecar_eeg,[rootfname,'_',fnamesuf,'.json']);
channels=mk_channels(EEG,[rootfname,'_',fnamesuf,'.set']);
cell2tsv([rootfname,'_channels.tsv'],channels,'%s\t%s\t%s\n');
electrodes=mk_electrodes(EEG,[rootfname,'_',fnamesuf,'.set']);
cell2tsv([rootfname,'_electrodes.tsv'],electrodes,'%s\t%5.3f\t%5.3f\t%5.3f\t%s\t%s\n');
events=mk_events(EEG,[rootfname,'_',fnamesuf,'.set']);
cell2tsv([rootfname,'_events.tsv'],events,'%5.3f\t%5.3f\t%s\n');
[chan_struct,comp_struct,time_struct]=mk_marks(EEG,[rootfname,'_',fnamesuf,'.set']);
savejson('',chan_struct,[rootfname,'_chan_info.json']);
savejson('',comp_struct,[rootfname,'_comp_info.json']);
savejson('',time_struct,[rootfname,'_time_info.json']);


