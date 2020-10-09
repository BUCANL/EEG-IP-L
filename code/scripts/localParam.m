% Quick s01 local tester

montage_info = [0.500 -22.000 -48.000 -0.065 0.000 -1.580 1060.000 1260.000 1220.000];
staging_script = '';
aref_trim = 30;
recur_sec = 1;
limit_sec = [0 1];
sd_t_meth = 'q';
sd_t_vals = [.3 .7];
sd_t_o = 16;
sd_t_f_meth = 'fixed';
sd_t_f_vals = [];
sd_t_f_o = .2;
sd_t_pad = 1;
sd_ch_meth = 'q';
sd_ch_vals = [.3 .7];
sd_ch_o = 16;
sd_ch_f_meth = 'fixed';
sd_ch_f_vals = [];
sd_ch_f_o = .2;
ref_loc_file = 'derivatives/EEG-IP-L/code/misc/standard_1020_ll_ref19.elc';
low_bound_hz = 1;
high_bound_hz = 60;
save_f_res = 1;
n_nbr_ch = 3;
r_ch_meth = 'q';
r_ch_vals = [.3 .7];
r_ch_o = 16;
r_ch_f_meth = 'fixed';
r_ch_f_vals = [];
r_ch_f_o = .2;
bridge_trim = 40;
bridge_z = 6;
n_nbr_t = 3;
r_t_meth = 'q';
r_t_vals = [.3 .7];
r_t_o = 16;
r_t_f_meth = 'fixed';
r_t_f_vals = [];
r_t_f_o = .2;
min_gap_ms = 2000;

% Build marks structure if it does not exist.
if ~isfield(EEG,'marks')
    if isempty(EEG.icaweights)
        EEG.marks=marks_init(size(EEG.data));
    else
        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));
    end
end

% Mark added to tell if time has been lost
EEG.marks = marks_add_label(EEG.marks,'time_info', {'init_ind',[0,0,1],[1:EEG.pnts]});

% Execute the staging script if specified.
if isempty(staging_script)
    [ssp,ssn,sse]=fileparts(staging_script);
    addpath(ssp);
    eval(ssn);
end

% Warp locations to standard head surface:
if ~isempty(montage_info)
    EEG = warp_locs( EEG,ref_loc_file, ...
        'transform',montage_info, ...
        'manual','off');
end

% Window the continuous data
EEG = marks_continuous2epochs(EEG,'recurrence',recur_sec,'limits',limit_sec);

% Determines comically bad channels, and leaves them out of average rereference
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,trim_ch_sd]=chan_variance(EEG,'data_field','data', ...
         'chan_inds',chan_inds, ...
         'epoch_inds',epoch_inds, ...
         'plot_figs','off');

chan_dist=zeros(size(trim_ch_sd));
for i=1:size(trim_ch_sd,2)
    chan_dist(:,i)=(trim_ch_sd(:,i)-median(trim_ch_sd(:,i)))/diff(quantile(trim_ch_sd(:,i),[.3,.7]));
end
mean_chan_dist=mean(chan_dist,2);
m=median(mean_chan_dist);
q=quantile(mean_chan_dist,[.3,.7]);

refchans=find(mean_chan_dist<m+6*diff(q));

EEG.data=EEG.data-repmat(mean(EEG.data(chan_inds(refchans),:,:),1),size(EEG.data,1),1);
% end rereference block

%% CALCULATE DATA SD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This flag calculates the standard deviation  of the channels. Epochs are flagged if they
% are above the SD critical value. This flag identifies comically bad epochs.

% Calculate standard deviation of activation on non-'manual' flagged channels and epochs...
% logging_log('INFO', 'Calculating the data sd array for time criteria...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,data_sd_t]=chan_variance(EEG,'data_field','data', ...
    'chan_inds',chan_inds, ...
    'epoch_inds',epoch_inds, ...
    'plot_figs','off');
% logging_log('INFO', 'CALCULATED EPOCH SD...');

% Create the window criteria vector for flagging ch_sd time_info...
% logging_log('INFO', 'Assessing window data sd distributions...')
if strcmp(sd_t_meth,'na')
    flag_sd_t_inds=[];
else
    [~,flag_sd_t_inds]=marks_array2flags(data_sd_t, ...
        'flag_dim','col', ...
        'init_method',sd_t_meth, ...
        'init_vals',sd_t_vals, ...
        'init_crit',sd_t_o, ...
        'flag_method',sd_t_f_meth,... % 'fixed', ...
        'flag_vals',sd_t_f_vals, ... % NEW
        'flag_crit',sd_t_f_o, ... % 'flag_val',[sd_t_p], ...
        'plot_figs','on');
end
% logging_log('INFO', 'CREATED EPOCH CRITERIA VECTOR...');

% Edit the time flag info structure
% logging_log('INFO', 'Updating epflaginfo structure...');
chsd_epoch_flags = zeros(size(EEG.data(1,:,:)));
chsd_epoch_flags(1,:,epoch_inds(flag_sd_t_inds))=1;
chsd_epoch_flags=padflags(EEG,chsd_epoch_flags,sd_t_pad,'value',.5);
EEG.marks = marks_add_label(EEG.marks,'time_info', ...
{'ch_sd',[0,0,1],chsd_epoch_flags});
% logging_log('INFO', 'EDITED TIMEFLAGINFO STRUCT...');

% Combine ch_sd time_info flags into 'manual'...
EEG = pop_marks_merge_labels(EEG,'time_info',{'ch_sd'},'target_label','manual');
% logging_log('INFO', 'COMBINED MARKS STRUCTURE INTO MANUAL FLAGS...');

%% CALCULATE DATA SD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This flag calculates the standard deviation  of the channels. Channels are flagged if they
% are above the SD critical value. This flag identifies comically bad channels.

% Calculate standard deviation of activation on non-'manual' flagged channels and epochs...
% logging_log('INFO', 'Calculating the data sd array for channel criteria...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,data_sd_ch]=chan_variance(EEG,'data_field','data', ...
    'chan_inds',chan_inds, ...
    'epoch_inds',epoch_inds, ...
    'plot_figs','off');
% logging_log('INFO', 'CALCULATED CHAN SD...');

% Create the window criteria vector for flagging ch_sd chan_info...
% logging_log('INFO', 'Assessing window data sd distributions...')
[~,flag_sd_ch_inds]=marks_array2flags(data_sd_ch, ...
    'flag_dim','row', ...
    'init_method',sd_ch_meth, ...
    'init_vals',sd_ch_vals, ...
    'init_crit',sd_ch_o, ...
    'flag_method',sd_ch_f_meth, ... %fixed
    'flag_vals',sd_ch_f_vals, ...
    'flag_crit',sd_ch_f_o, ...
    'plot_figs','off');
% logging_log('INFO', 'CREATED CHANNEL CRITERIA VECTOR...');

% Edit the channel flag info structure
% logging_log('INFO', 'Updating chflaginfo structure...');
chsd_chan_flags = zeros(EEG.nbchan,1);
chsd_chan_flags(chan_inds(flag_sd_ch_inds)) = 1;
EEG.marks = marks_add_label(EEG.marks,'chan_info', ...
{'ch_sd',[.7,.7,1],[.2,.2,1],-1,chsd_chan_flags});
% logging_log('INFO', 'EDITED CHANFLAGINFO STRUCT...');

% Combine ch_sd chan_info flags into 'manual'...
EEG = pop_marks_merge_labels(EEG,'chan_info',{'ch_sd'},'target_label','manual');
% logging_log('INFO', 'COMBINED MARKS STRUCTURE INTO MANUAL FLAGS...');

% Concatenate epoched data back to continuous data
% logging_log('INFO', 'Concatenating windowed data...');
EEG = marks_epochs2continuous(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');
% logging_log('INFO', 'CONCATENATED THE WINDOWED DATA INTO CONTINUOUS DATA...');

%% REREFERENCE TO INTERPOLATED AVERAGE SITE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rereference the data to an average interpolated site containing 19 channels
% ... excluding 'manual' flagged channels from the calculation

% logging_log('INFO', 'Rereferencing to averaged interpolated site...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
EEG = interp_ref(EEG,ref_loc_file,'chans',chan_inds);
EEG = eeg_checkset(EEG);
% logging_log('INFO', 'REREFERENCED TO INTERPOLATED AVERAGE SITE...');

%% FILTER HIGH PASS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filters the data to remove frequencies lower than the selected value. The residuals that
% were removed can be saved for further analysis if needed.
% logging_log('INFO', 'High pass filtering the data...');
if([low_bound_hz])
    EEG = pop_eegfiltnew(EEG,[],[low_bound_hz],[],true,[],0);
end
    
%% FILTER LOW PASS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filters the data to remove frequencies higher the selected value. The residuals that
% were removed can be saved for further analysis if needed.
% logging_log('INFO', 'Low pass filtering the data...');
if([high_bound_hz])
    EEG = pop_eegfiltnew(EEG,[],[high_bound_hz],[],0,[],0);
end

%% CALCULATE NEAREST NEIGHBOUR R VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks neighboring channels for too high or low of a correlation.

% Window the continuous data
% logging_log('INFO', 'Windowing the continous data...');
EEG = marks_continuous2epochs(EEG,'recurrence',recur_sec,'limits',limit_sec);
% logging_log('INFO', 'WINDOWED THE CONTINUOUS DATA...');

% Calculate nearest neighbout correlation on non-'manual' flagged channels and epochs...
% logging_log('INFO', 'Calculating nearst neighbour r array for channel criteria...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,data_r_ch,~,~,~] = chan_neighbour_r(EEG, ...
    n_nbr_ch,'max', ...
    'chan_inds',chan_inds, ...
    'epoch_inds',epoch_inds, ...
    'plot_figs','off');

% Create the window criteria vector for flagging low_r chan_info...
% logging_log('INFO', 'Assessing channel r distributions criteria...')
[~,flag_r_ch_inds]=marks_array2flags(data_r_ch, ...
    'flag_dim','row', ...
    'init_method',r_ch_meth, ...
    'init_vals',r_ch_vals, ...
    'init_dir','neg', ...
    'init_crit',r_ch_o, ...
    'flag_method',r_ch_f_meth, ...
    'flag_vals',r_ch_f_vals, ...
    'flag_crit',r_ch_f_o, ...
    'plot_figs','off');

% Edit the channel flag info structure
% logging_log('INFO', 'Updating chflaginfo structure...');
lowr_chan_flags = zeros(EEG.nbchan,1);
lowr_chan_flags(chan_inds(flag_r_ch_inds))=1;
EEG.marks = marks_add_label(EEG.marks,'chan_info', ...
    {'low_r',[1,.7,.7],[1,.2,.2],-1,lowr_chan_flags});

% logging_log('INFO', 'CALCULATED NEAREST NEIGHBOUR R VALUES...');

%% IDENTIFY BRIDGED CHANNELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses the correlation of neighboors calculated to flag bridged channels.

% logging_log('INFO', 'Examing nearest neighbour r array for linked channels...');
mr = median(data_r_ch,2);
iqrr = iqr(data_r_ch,2);
msr = mr./iqrr;
flag_b_chan_inds = find(msr>ve_trimmean(msr,bridge_trim,1)+ve_trimstd(msr,bridge_trim,1)*bridge_z);

% Edit the channel flag info structure
% logging_log('INFO', 'Updating chflaginfo structure...');
lnkflags = zeros(EEG.nbchan,1);
lnkflags(chan_inds(flag_b_chan_inds))=1;
EEG.marks = marks_add_label(EEG.marks,'chan_info', ...
    {'bridge',[.7,1,.7],[.2,1,.2],-1,lnkflags});
% logging_log('INFO', 'EDITED CHANFLAGINFO STRUCT...');

% Combine low_rand bridge chan_info flags into 'manual'...
EEG = pop_marks_merge_labels(EEG,'chan_info',{'low_r','bridge'},'target_label','manual');
% logging_log('INFO', 'COMBINED MARKS STRUCTURE INTO MANUAL FLAGS...');

%% FLAG RANK CHAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Flags the channel that is the least unique (the best channel to remove prior 
% to ICA in order to account for the rereference rank deficiency.

% logging_log('INFO', 'Updating chflaginfo structure...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
[r_max,rank_ind] = max(data_r_ch(chan_inds));
rankflags = zeros(EEG.nbchan,1);
rankflags(chan_inds(rank_ind))=1;
EEG.marks = marks_add_label(EEG.marks,'chan_info', ...
    {'rank',[.1,.1,.24],[.1,.1,.24],-1,rankflags});
% logging_log('INFO', 'EDITED CHANFLAGINFO STRUCT...');

%% REREFERENCE TO INTERPOLATED AVERAGE SITE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rereference the data to an average interpolated site containined 19 channels
% logging_log('INFO', 'Rereferencing to averaged interpolated site...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
EEG = interp_ref(EEG,ref_loc_file,'chans',chan_inds);
EEG = eeg_checkset(EEG);
% logging_log('INFO', 'REREFERENCED TO INTERPOLATED AVERAGE SITE...');

%% CALCULATE NEAREST NEIGHBOUR R VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Similarly to the neighbor r calculation done between channels this section looks
% at the correlation, but between all channels and for epochs of time. Time segmenents 
% are flagged for removal.

% logging_log('INFO', 'Calculating nearest neighbour r array for window criteria...');
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,data_r_t,~,~,~] = chan_neighbour_r(EEG, ...
    n_nbr_t,'max', ...
    'chan_inds',chan_inds, ...
    'epoch_inds',epoch_inds, ...
    'plotfigs','off');
% logging_log('INFO', 'CALCULATED NEAREST NEIGHBOUR R VALUES...');

% Create the window criteria vector for flagging low_r time_info...
% logging_log('INFO', 'Assessing epoch r distributions criteria...')
[~,flag_r_t_inds]=marks_array2flags(data_r_t, ...
    'flag_dim','col', ...
    'init_method',r_t_meth, ...
    'init_vals',r_t_vals, ...
    'init_dir','neg', ...
    'init_crit',r_t_o, ...
    'flag_method',r_t_f_meth, ...
    'flag_vals',r_t_f_vals, ...
    'flag_crit',r_t_f_o, ...
    'plot_figs','off');
% logging_log('INFO', 'CREATED EPOCH CRITERIA VECTOR...');

% Edit the time flag info structure
% logging_log('INFO', 'Updating latflaginfo structure...');
lowr_epoch_flags = zeros(size(EEG.data(1,:,:)));
lowr_epoch_flags(1,:,epoch_inds(flag_r_t_inds))=1;
EEG.marks = marks_add_label(EEG.marks,'time_info', ...
    {'low_r',[0,1,0],lowr_epoch_flags});
clear lowr_epoch_flags;
% logging_log('INFO', 'TIME TO: UPDATE REJECTION STRUCTURE...');

% Combine low_r time_info flags into 'manual'...
EEG = pop_marks_merge_labels(EEG,'time_info',{'low_r'},'target_label','manual');
% logging_log('INFO', 'COMBINED MARKS STRUCTURE INTO MANUAL FLAGS...');

% Concatenate epoched data back to continuous data
% logging_log('INFO', 'Concatenating windowed data...');
EEG = marks_epochs2continuous(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');
% logging_log('INFO', 'CONCATENATED THE WINDOWED DATA INTO CONTINUOUS DATA...');

EEG=pop_marks_flag_gap(EEG,{'manual'},min_gap_ms,'mark_gap',[.8,.8,.8],'offsets',[0 0],'ref_point','both');

% Combine mark_gap time_info flags into 'manual'...
EEG = pop_marks_merge_labels(EEG,'time_info',{'mark_gap'},'target_label','manual');
% logging_log('INFO', 'COMBINED MARKS STRUCTURE INTO MANUAL FLAGS...');

disp('Done!');
