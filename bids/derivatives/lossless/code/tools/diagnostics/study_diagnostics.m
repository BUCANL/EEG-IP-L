function study_diagnostics(ALLEEG,batch_config)
% diagnostics(ALLEEG,type) - Creates figures to aid user in understanding
% the generated marks, and the overal quality of the data.
%
%Copyright (C) 2017 BUCANL
%
%Code originally written by James A. Desjardins with contributions from 
%Allan Campopiano and Andrew Lofts, supported by NSERC funding to 
%Sidney J. Segalowitz at the Jack and Nora Walker Canadian Centre for 
%Lifespan Development Research (Brock University), and a Dedicated Programming 
%award from SHARCNet, Compute Ontario.
%
%This program is free software; you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation; either version 2 of the License, or
%(at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program (LICENSE.txt file in the root directory); if not, 
%write to the Free Software Foundation, Inc., 59 Temple Place,
%Suite 330, Boston, MA  02111-1307  USA

data_chans = [];
data_time = [];
ica_chans = [];
sub_names = {};

for i=1:length(ALLEEG);
    
    EEG = ALLEEG(i);
    fprintf(['\nChecking marks for file ' EEG.filename '...\n']);
    
    fin_underscore = regexp(EEG.filename,'_');
    fin_underscore = fin_underscore(end);
    base_name = EEG.filename(5:fin_underscore-1);
    
    sub_names = horzcat(sub_names,base_name);
    
    %% Channels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\nChannels\n');
    fprintf('==================================================\n');
    for j = 1:length(EEG.marks.chan_info) 
        %just flags
        x = length(find(EEG.marks.chan_info(j).flags));
        % All chans
        y = length(EEG.marks.chan_info(j).flags);
        disp(['Flagged: ' num2str(x) '/' num2str(y) ' Channels for ' EEG.marks.chan_info(j).label]);
    end

    ca = length(EEG.marks.chan_info(1).flags);                % All time
    c2 = length(find(EEG.marks.chan_info(2).flags));          % 2
    c3 = length(find(EEG.marks.chan_info(3).flags));          % 3
    c4 = length(find(EEG.marks.chan_info(4).flags));          % 4
    cm = length(find(EEG.marks.chan_info(1).flags));          % 5
    ca = ca-cm;                                               % Remaining All time
    cpie = [ca c2 c3 c4];
    
    data_chans = vertcat(data_chans,cpie);
    
    %% Time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\nTime\n');
    fprintf('==================================================\n');
    for j = 1:length(EEG.marks.time_info) 
        %just flags
        x = length(find(EEG.marks.time_info(j).flags));
        % All time
        y = length(EEG.marks.time_info(j).flags);
        disp(['Flagged: ' num2str((x/y)*100) ' % of Time for ' EEG.marks.time_info(j).label]);
    end

    % outtask vs manual vs time remaining piechart
    ca = length(EEG.marks.time_info(1).flags); % All time
 
    co=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label({'out_task','in_leadup'},{EEG.marks.time_info.label}), ...
        'indices'));

    mgap=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('mark_gap',{EEG.marks.time_info.label}), ...
        'indices'));

    chsd=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('ch_sd',{EEG.marks.time_info.label}), ...
        'indices'));

    lowr=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('low_r',{EEG.marks.time_info.label}), ...
        'indices'));

    icsd1=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('ic_sd1',{EEG.marks.time_info.label}), ...
        'indices'));
    
    icsd2=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('ic_sd2',{EEG.marks.time_info.label}), ...
        'indices'));

    cm=length(marks_label2index(EEG.marks.time_info, ...
        marks_match_label('manual',{EEG.marks.time_info.label}), ...
        'indices'));
    
    cr = ca-cm; % Remaining All time
    cpie = [cr co mgap chsd lowr icsd1 icsd2];
    
    data_time = vertcat(data_time,cpie);
    
    %% Components
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('\nICA Components\n');
    fprintf('==================================================\n');
    disp(['Identified ' num2str(min(size(EEG.icaweights))) ' components from ' num2str(length(EEG.icachansind)) ' channels']);

    ca = length(find(EEG.reject.classtype == 1));
    c2 = length(find(EEG.reject.classtype == 2));
    c3 = length(find(EEG.reject.classtype == 3));
    c4 = length(find(EEG.reject.classtype == 4));
    c5 = length(find(EEG.reject.classtype == 5));
    c6 = length(find(EEG.reject.classtype == 6));
    cpie = [ca c2 c3 c4 c5 c6];
    
    ica_chans = vertcat(ica_chans,cpie);
    
end

%% Mean Channel Breakdown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_chan_m = mean(data_chans);
figure;
explode = [1 0 0 0];
labels = {'Remaining Channels','ch-sd','low-r','bridge'};
pie(data_chan_m,explode,labels); colormap(jet);
title('Data Channel Classification');

figure; bar(data_chans,'stacked');
title('Data Channel Classification');
legend(labels);
set(gca,'XTick',[1:length(sub_names)]);
set(gca,'XTickLabel',sub_names);
rotatetl(gca,90,'b');
xlabel('Subject #');
ylabel('# of Channels');
x_pos = get(get(gca, 'XLabel'), 'Position');
set(get(gca, 'XLabel'), 'Position', x_pos + [0 -3 0]);

%% Mean and Sum Time Breakdown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mean_time = mean(data_time);

% Mean Time Breakdown
figure;
explode = [1 0 0 0 0 0 0];
labels = {'Remaining Time','out-task','mark-gap','ch-sd','low-r','ic-sd1','ic-sd2'};
pie(mean_time,explode,labels); colormap(jet);
title('Mean Time Classification Breakdown across all Subjects');

figure; bar(data_time,'stacked');
title('Mean Time Classification Breakdown for each Subject');
legend(labels);
set(gca,'XTick',[1:length(sub_names)]);
set(gca,'XTickLabel',sub_names);
rotatetl(gca,90,'b');
x_pos = get(get(gca, 'XLabel'), 'Position');
set(get(gca, 'XLabel'), 'Position', x_pos + [0 -3 0]);
xlabel('Subject #');
ylabel('# of Time Points');
y_lab = get(gca,'YTick');
set(gca,'YTickLabel',num2str(y_lab'));

%% Mean Component Breakdown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ica_chan_m = mean(ica_chans);
figure;
explode = [0 1 0 0 0 0];
labels = {'blink','neural','heart','lateye','muscle','mixed'};
pie(ica_chan_m,explode,labels); colormap(jet);
title('Component Classification Breakdown across all Subjects');

figure; bar(ica_chans,'stacked');
title('Component Classification Breakdown for each Subject');
legend(labels);
set(gca,'XTick',[1:length(sub_names)]);
set(gca,'XTickLabel',sub_names);
rotatetl(gca,90,'b');
xlabel('Subject #');
ylabel('# of Components');
x_pos = get(get(gca, 'XLabel'), 'Position');
set(get(gca, 'XLabel'), 'Position', x_pos + [0 -3 0]);
