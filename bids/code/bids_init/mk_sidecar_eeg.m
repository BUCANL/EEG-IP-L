function sidecar_eeg=mk_sidecar_eeg(EEG,fname)

% load current file only if it hasn't been loaded already
if ~exist('EEG','var') || (exist('EEG','var') && isempty(EEG)) || ...
  (~isempty(EEG) && ~strcmp(fname,[EEG.filepath '/' EEG.filename]));
    EEG = pop_loadset('filename',fname);
end

[path,fname,ext] = fileparts(fname);
disp(['Creating ' fname '.json file...']);

sidecar_eeg.TaskName='all';
sidecar_eeg.TaskDescription='';
sidecar_eeg.Instructions='';
sidecar_eeg.CogAltasID='';
sidecar_eeg.CogPOID='';
sidecar_eeg.InstitutionName='';
sidecar_eeg.InstitutionAddress='';
sidecar_eeg.DeviceSerialNumber='';

sidecar_eeg.EEGSamplingFrequency=EEG.srate;
sidecar_eeg.ManufacturersAmplifierModelName='';
sidecar_eeg.ManufacturerCapModelName='';
sidecar_eeg.EEGChannelCount=EEG.nbchan;
sidecar_eeg.EOGChannelCount='';
sidecar_eeg.EMGChannelCount='';
sidecar_eeg.MiscChannelCount='';
sidecar_eeg.TriggerChannelCount='';
sidecar_eeg.PowerLineFrequency='';
sidecar_eeg.EEGPlacementScheme='';
sidecar_eeg.EEGReference=EEG.ref;
sidecar_eeg.HardwareFilters='';
sidecar_eeg.SoftwareFilters='';
sidecar_eeg.RecordingDuration=EEG.pnts*(1/EEG.srate);
if EEG.trials==1;
    sidecar_eeg.RecordingType='continuous';
    sidecar_eeg.EpochLength='Inf';
else
    sidecar_eeg.RecordingType='epoched';
    sidecar_eeg.EpochLength=EEG.xmax-EEGxmin;
end
sidecar_eeg.DeviceSoftwareVersion='';
sidecar_eeg.SubjectArtefactDescription='';
sidecar_eeg.DigitizedLandmarks='';
sidecar_eeg.DigitizedHeadPoints='';
sidecar_eeg.DigitizedElectrodes='';