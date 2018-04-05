function vised_config=init_vised_config

%vised options
vised_config.pop_gui='on';
vised_config.data_type='';%currently EEG or ICA
%vised_config.chans='';%this should allow chan/component labels or marks labels.. now accespts stings at least...
%vised_config.event_type={};%event types (labels)

vised_config.winrej_marks_labels={};
vised_config.quick_evtmk='';
vised_config.quick_evtrm='off';
vised_config.quick_chanflag='off';
        
vised_config.chan_marks_struct='';%store name of marks structure... if empty EEG.marks.chaninfo
vised_config.time_marks_struct='';%store name of marks structure... if empty EEG.marks.timeinfo
vised_config.marks_y_loc=[];
vised_config.inter_mark_int=[];
vised_config.inter_tag_int=[];
vised_config.marks_col_int=[];
vised_config.marks_col_alpha=[];

%eegplot options
%vised_config.srate=[];%store sample rate value or name of sample rate var... if empty EEG.srate... implemented
vised_config.spacing=[];
vised_config.eloc_file='';%store name of channel location structure or location fname... if empty EEG.chanlocs
vised_config.limits=[];
vised_config.freqlimits=[];
vised_config.winlength=[];
vised_config.dispchans=[];
vised_config.title='';
vised_config.xgrid='off';
vised_config.ygrid='off';
vised_config.ploteventdur='off';
vised_config.data2='';%store name of data array... implemented..
vised_config.command='';
vised_config.butlabel='';
%vised_config.winrej='';%REMOVE... always determined by winrej_marks_labels... implemented... 
vised_config.color='';
vised_config.wincolor=[];
%vised_config.colmodif={};%REMOVE.. depricated.. not used ... implemented...
%vised_config.tmp_events=[];%REMOVE.. this needs to be handed to ve_eegplot but should not be stored in the config... always created from vised_config.event_type
vised_config.submean='on';
vised_config.position=[];
vised_config.tag='vef';
vised_config.children='';
vised_config.scale='on';
vised_config.mocap='';
        
vised_config.selectcommand={''};
vised_config.altselectcommand={''};
vised_config.extselectcommand={''};
vised_config.keyselectcommand={''};
        
vised_config.mouse_data_front='off';

vised_config.trialstag=[];
vised_config.datastd=[];
vised_config.normed=[];
vised_config.envelope=[];
vised_config.chaninfo=[];
