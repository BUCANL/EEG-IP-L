%% SCRIPT DESCRIPTION
% This script utilizes pipeline_clean to cleanup the logs and preproc
% directory for files that complete the pipeline
%
%% From Config          key_strswap         Description
%-----------------------------------------------------------------------------------------------------------------------------
%    in_path =           [in_path]           Relative path to input data files assuming cd = work_path
% preproc_amica_param =  [preproc_amica_param] clean preproc_amica_param entries
% preproc_amicaout =     [preproc_amicaout] clean preproc_amiacout entries
% preproc_concat_data =  [preproc_concat_data] clean preproc_concat_data entries
% preproc_concat_asr =   [preproc_concat_asr] clean preproc_concat_asr entries
% preproc_sa =           [preproc_sa] clean preproc_sa entries
% preproc_sa_purge =     [preproc_sa_purge] clean preproc_sa_purge entries
% preproc_asr =          [preproc_asr] clean preproc_asr entries
% preproc_asr_purge =    [preproc_asr_purge] clean preproc_asr_purge entries
% preproc_compart_data_purge = [preproc_compart_data_purge] clean preproc_compart_data_purge entries
% preproc_compart_data = [preproc_compart_data] clean preproc_compart_data entries
% preproc_dip =          [preproc_dip] clean preproc_dip entries
% trash_root =           [trash_root] clean study root
% zip_successful_logs =  [zip_successful_logs] zip successful logs
% delete_successful_logs = [delete_successful_logs] delete logs that are zipped
% use_system_xz =        [use_system_xz] use system xz instead of zip
% use_system_gzip =      [use_system_gzip] use system gzip instead of zip
% use_zip =              [use_zip] use matlab zip

logging_log('NOTICE', 'Starting cleanup');

opts.preproc_amica_param = [preproc_amica_param];
opts.preproc_amicaout = [preproc_amicaout];
opts.preproc_concat_data = [preproc_concat_data];
opts.preproc_concat_asr = [preproc_concat_asr];
opts.preproc_sa = [preproc_sa];
opts.preproc_sa_purge = [preproc_sa_purge];
opts.preproc_asr = [preproc_asr];
opts.preproc_asr_purge = [preproc_asr_purge];
opts.preproc_compart_data_purge = [preproc_compart_data_purge];
opts.preproc_compart_data = [preproc_compart_data];
opts.preproc_dip = [preproc_dip];
opts.trash_root = [trash_root];
opts.zip_successful_logs = [zip_successful_logs];
opts.delete_successful_logs = [delete_successful_logs];
opts.use_system_xz = [use_system_xz];
opts.use_system_gzip = [use_system_gzip];
opts.use_zip = [use_zip];

pipeline_clean('[batch_dfn]', '[mfile_name]', '[in_path]', opts);

logging_log('NOTICE', 'Completed cleanup');
print_chan_sample([]);
