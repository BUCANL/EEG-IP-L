%load corresponding coordinate file
EEG = warp_locs( EEG, 'derivatives/lossless/code/misc/standard_1005.elc', ...
      'mesh','derivatives/lossless/code/misc/standard_vol_SCCN.mat', ...
      'transform',[0.6,-22,-3,-0.05,-0.003,-1.57,10.2,11,11.6], ...
      'manual','off');

EEG = pop_eegfiltnew(EEG,[],1,[],true,[],0);

if ~isfield(EEG,'marks');
    EEG.marks = marks_init(size(EEG.data));
end

% Apply trimmed average re-reference
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
trm_m = ve_trimmean(EEG.data(chan_inds,:),30,1);
trm_m_mat = repmat(trm_m,size(EEG.data,1),1);
EEG.data = EEG.data - trm_m_mat;
clear trm_m_mat;

% epoch the continuous data
EEG = marks_continuous2epochs(EEG,'recurrence',[1],'limits',[0 1]);

% flag fixed criteria time points
chan_inds = marks_label2index(EEG.marks.chan_info,{'manual'},'indexes','invert','on');
epoch_inds = marks_label2index(EEG.marks.time_info,{'manual'},'indexes','invert','on');
[EEG,data_s_sd_t]=chan_variance(EEG,'data_field','data', ...
         'chan_inds',chan_inds, ...
         'epoch_inds',epoch_inds, ...
         'plot_figs','off');

[~,flag_s_sd_t_inds]=marks_array2flags(data_s_sd_t, ...
             'flag_dim','col', ...
             'init_method','fixed', ...
             'init_vals',[0 50], ...
             'init_crit',[], ...
             'flag_method','fixed', ...
             'flag_val',.3, ...
             'plot_figs','off');
chsd_epoch_flags = zeros(size(EEG.data(1,:,:)));
chsd_epoch_flags(1,:,epoch_inds(flag_s_sd_t_inds))=1;
chsd_epoch_flags=padflags(EEG,chsd_epoch_flags,1,'value',.5);
EEG.marks = marks_add_label(EEG.marks,'time_info', ...
            {'ch_s_sd',[1,0,0],chsd_epoch_flags});
EEG = pop_marks_merge_labels(EEG,'time_info',{'ch_s_sd'},'target_label','manual');

% concatenate the epoched data
EEG = marks_epochs2continuous(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');

