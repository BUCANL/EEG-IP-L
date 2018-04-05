function init_bids_sub(EEG,rootfname)

sidecar_eeg=mk_sidecar_eeg(EEG,[rootfname,'_eeg.set']);
savejson('',sidecar_eeg,[rootfname,'_eeg.json']);
channels=mk_channels(EEG,[rootfname,'_eeg.set']);
cell2tsv([rootfname,'_channels.tsv'],channels,'%s\t%s\t%s\n');
electrodes=mk_electrodes(EEG,[rootfname,'_eeg.set']);
cell2tsv([rootfname,'_electrodes.tsv'],electrodes,'%s\t%5.3f\t%5.3f\t%5.3f\t%s\t%s\n');
events=mk_events(EEG,[rootfname,'_eeg.set']);
cell2tsv([rootfname,'_events.tsv'],events,'%5.3f\t%5.3f\t%s\n');