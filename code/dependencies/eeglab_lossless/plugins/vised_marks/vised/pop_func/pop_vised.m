%% FRONT MATTER...

% pop_VisEd() - Collect variables for visual editing.
%
% Usage: 
%   >>  EEG = pop_VisEd( EEG, chan_index, event_type,varargin);
%
%   chan_index   - EEG channels to display in eegplot figure window while editing events and identifying bad channels.
%   event_type   - Event types to display in eegplot figure window while editing events and identifying bad channels.
%    
% Outputs:
%   EEG  - output dataset
%
% UI for selecting EEG channels and event types to be displayed in eegplot
% figure window while editing events and identifying bad channels.
%
% Calls function EEG=VisEd(EEG,chan_index,event_type);
%
% See also:
%   EEGLAB 

% Copyright (C) <2008>  <James Desjardins> Brock University
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%% START MAIN FUNCTION...
function [EEG,com]=pop_vised(EEG, varargin)%data_type, chan_index, event_type, varargin)

%% INITIATE VISED_CONFIG OBJECT

try parameters = evalin('base', 'vised_config');
    vised_config=parameters;
catch %if nonexistent in workspace
    vised_config=init_vised_config;
end

vised_option_names={'pop_gui','chans','event_type','winrej_marks_labels','quick_evtmk','quick_evtrm','quick_chanflag'};

%% initiate marks field if it does not already exist...
if ~isfield(EEG,'marks');
    if isempty(EEG.icaweights)
        EEG.marks = marks_init(size(EEG.data));
    else
        EEG.marks = marks_init(size(EEG.data),min(size(EEG.icaweights)));
    end
end

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1})
            options{index} = { options{index} };
        end
    end;
    if ~isempty( varargin ),
        g=struct(options{:});
    else
        g= [];
    end;
catch
    disp('ve_eegplot() error: calling convention {''key'', value, ... } error'); return;
end;


% 'data_type', if it is not in varargin, and empty in base vised_config make
% the default 'EEG'.
try
    vised_config.data_type=g.data_type;
catch
    if isempty(vised_config.data_type)
        vised_config.data_type='EEG';
    end
end


% Handle options that are not included in vised_config.
% These options are not stored in vised_config because they should not be
% remembered in the default workspace. If they are remembered in base
% workspace they can result in confusing or erroneous usage.

% 'chans' stores the channel/comp indices to plot.
% This variable is not stored in vised_config.
% 'chans' is initially determined fresh from the EEG structure on every run.
% 'chans', if it is not in varargin make the default equal to the indices
% of either either EEG or ICA arrays based on 'data_type'
chans = '';
try 
    chans=g.chans;
catch
    switch vised_config.data_type;
        case 'EEG'
            chans=vararg2str(1:EEG.nbchan);
        case 'ICA'
            chans=vararg2str(1:min(size(EEG.icaweights)));
    end
end

% check for numeric event.type entries.. if found change to strings.
j=0;
for i=1:length(EEG.event)
    if isnumeric(EEG.event(i).type)
        j=j+1;
        if j==1
            disp('at least one event.type is numeric... changing to string...');
        end            
        EEG.event(i).type=num2str(EEG.event(i).type);
    end
end
% 'event_type' stores the unique event labels to plot.
% This variable is not stored in vised_config.
% 'event_type' is initially determined fresh from the EEG structure on every run.
% 'event_type', if it is not in varargin make the default equal to the indices
% of either EEG or ICA arrays based on 'data_type'
event_type = {};
try 
    event_type=g.event_type;
catch
    if isempty(EEG.event);
        event_type={};
    else
        event_type=unique({EEG.event.type});
    end
end

% 'srate'
srate = [];
try 
    srate=g.srate;
catch
    srate=EEG.srate;
end


% 'pop_gui', if it is not in varargin, and empty in base vised_config make
% the default 'on'.
try
    vised_config.pop_gui=g.pop_gui;
catch
    if isempty(vised_config.pop_gui);
        vised_config.pop_gui='on';
    end
end;


%INSERT g options into vised_config else defaults...
%vised_options...
try vised_config.winrej_marks_labels = g.winrej_marks_labels;
catch, if isempty(vised_config.winrej_marks_labels);vised_config.winrej_marks_labels='manual';end
end

try vised_config.quick_evtmk=g.quick_evtmk;
catch, if isempty(vised_config.quick_evtmk);vised_config.quick_evtmk='';end
end

try vised_config.quick_evtrm=g.quick_evtrm;
catch, if isempty(vised_config.quick_evtrm);vised_config.quick_evtrm='off';end
end

try vised_config.quick_chanflag=g.quick_chanflag;
catch, if isempty(vised_config.quick_chanflag);vised_config.quick_chanflag='off';end
end

try vised_config.chan_marks_struct=g.chan_marks_struct;
catch, 
end

try vised_config.time_marks_struct=g.time_marks_struct;
catch, if isempty(vised_config.time_marks_struct);vised_config.time_marks_struct='EEG.marks.time_info';end
end

eval(['tmp.time_marks_struct=',vised_config.time_marks_struct,';']);

try vised_config.marks_y_loc=g.marks_y_loc;
catch, if isempty(vised_config.marks_y_loc);vised_config.marks_y_loc=.8;end
end

try vised_config.inter_mark_int=g.inter_mark_int;
catch, if isempty(vised_config.inter_mark_int);vised_config.inter_mark_int=.04;end
end

try vised_config.inter_tag_int=g.inter_tag_int;
catch, if isempty(vised_config.inter_tag_int);vised_config.inter_tag_int=.002;end
end

try vised_config.marks_col_int=g.marks_col_int;
catch, if isempty(vised_config.marks_col_int);vised_config.marks_col_int=.1;end
end

try vised_config.marks_col_int=g.marks_col_alpha;
catch, if isempty(vised_config.marks_col_alpha);vised_config.marks_col_alpha=.7;end
end


%eegplot_options...

% 'srate' has been removed because it should always be obtained from
% EEG.srate (but can still be over written via varagr in for rare corner
% cases).
%try vised_config.srate=g.srate;                           catch,end

try vised_config.spacing = g.spacing;                     catch,end
try vised_config.eloc_file = g.eloc_file;                 catch,end
try vised_config.winlength = g.winlength;                 catch,end
try vised_config.position=g.position;                     catch,end
try vised_config.title = g.title;                         catch,end
try vised_config.trialstag = g.trialstag;                 catch,end
try vised_config.winrej = g.winrej;                       catch,end

try vised_config.command = g.command;
catch,if isempty(vised_config.command);vised_config.command='EEG=ve_update(EEG);EEG.saved = ''no'';';end
end

try vised_config.tag = g.tag;                             catch,end
try vised_config.xgrid=g.xgrid;                           catch,end
try vised_config.ygrid=g.ygrid;                           catch,end
try vised_config.color = g.color;                         catch,end
try vised_config.submean = g.submean;                     catch,end
try vised_config.children = g.children;                   catch,end
try vised_config.limits = g.limits;                       catch,end
try vised_config.freqlimits = g.freqlimits;               catch,end
try vised_config.dispchans = g.dispchans;                 catch,end

try vised_config.wincolor = g.wincolor;
catch, if isempty(vised_config.wincolor);vised_config.wincolor=[0.7 1 0.9];end
end

try vised_config.butlabel = g.butlabel;
catch,if isempty(vised_config.butlabel);vised_config.butlabel='Update EEG structure';end
end

try vised_config.colmodif = g.colmodif;                   catch,end
try vised_config.scale=g.scale;                           catch,end
try vised_config.events = g.events;                       catch,end
try vised_config.ploteventdur = g.ploteventdur;           catch,end
try vised_config.data2 = g.data2;                         catch,end
try vised_config.plotdata2 = g.plotdata2;                 catch,end
try vised_config.mocap = g.mocap;                         catch,end

try vised_config.selectcommand = g.selectcommand;
catch,
    if isempty(vised_config.selectcommand{1}); vised_config.selectcommand={['ve_eegplot(''defdowncom'',gcbf);']; ...
                                                                           ['ve_eegplot(''defmotioncom'',gcbf);']; ...
                                                                           ['ve_eegplot(''defupcom'', gcbf);']};
    end
end

try vised_config.extselectcommand=g.extselectcommand;     catch 
        if isempty(vised_config.extselectcommand{1})
            vised_config.extselectcommand={ ['ve_edit;']; ['ve_eegplot(''defmotioncom'', gcbf);']; [''] };
        end
end
try vised_config.altselectcommand=g.altselectcommand;     catch 
        if isempty(vised_config.altselectcommand{1})
            vised_config.altselectcommand={ ['ve_edit(''quick_chanflag'',''manual'');']; ['ve_eegplot(''defmotioncom'', gcbf);']; [''] };
        end
end
        
try vised_config.keyselectcommand=g.keyselectcommand;      catch
        if isempty(vised_config.keyselectcommand{1})
            vised_config.keyselectcommand={'t,ve_eegplot(''topoplot'',gcbf)';'r,ve_eegplot(''drawp'',0)'};
        end
end
    
try vised_config.datastd = g.datastd;                     catch, end;
try vised_config.normed = g.normed;                       catch, end;
try vised_config.envelope = g.envelope;                   catch, end;
try vised_config.chaninfo = g.chaninfo;                   catch, vised_config.chaninfo=EEG.chaninfo; end;


%check for unrecognized options...
if ~isempty(g);
    gfields = fieldnames(g);
    for index=1:length(gfields)
        switch gfields{index}
            case {  'pop_gui' 'data_type' 'vised_config_page' ...
                    'quick_evtmk' 'quick_evtrm' 'quick_chanflag' ...
                    'srate' 'spacing' 'eloc_file' 'winlength' 'position' 'title' ...
                    'trialstag'  'winrej' 'command' 'tag' 'xgrid' 'ygrid' 'color' ...
                    'submean' 'children' 'limits' 'freqlimits' 'dispchans' 'wincolor' ...
                    'butlabel' 'colmodif' 'scale' 'event_type' 'ploteventdur' 'data2' 'plotdata2' 'mocap' ...
                    'selectcommand' 'openselectcommand' 'altselectcommand' ...
                    'extselectcommand' 'keyselectcommand' 'datastd' 'normed' 'envelope' 'chaninfo' ...
                    'chan_marks_struct' 'time_marks_struct' ...
                    'marks_y_loc' 'inter_mark_int' 'inter_tag_int' 'winrej_marks_labels' ...
                    'marks_col_int' 'marks_col_alpha'},
            otherwise, error(['ve_eegplot: unrecognized option: ''' gfields{index} '''' ]);
        end;
    end;
end


%% CONVERT VISED_CONFIG STRUCTURE INTO STRING ... EXTRACT INPUTS ... *****THIS CELL SHOULD BE VISEDCONFIG2PROPGRIG***** BUILD PROPGRIDSTR

PropGridStr=['global vecp;', ...
    'vised_config = evalin(''caller'', ''vised_config'');' ... 
    'properties=visedconfig2propgrid(vised_config);' ...
    'properties = properties.GetHierarchy();' ...
    'vecp = PropertyGrid(gcf,' ...
    '''Properties'', properties,' ...
    '''Position'', [.04 .11 .92 .61]);' ...
    ];

update_global=0;
if strcmp(vised_config.pop_gui,'on');
    
    % PREPARE VARIABLES FOR POP UP WINDOW ...
    data_typeCell={'EEG'};
    if ~isempty(EEG.icaweights);
        data_typeCell={'EEG','ICA'};
    end
    switch vised_config.data_type
        case 'EEG'
            data_typeVal=1;
            chanlabel_callback=['tmpchanlocs = EEG.chanlocs;' ...
                '[ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel({tmpchanlocs.labels});' ...
                'set(findobj(gcbf,''tag'',''ChanIndexEdit''),''string'',vararg2str(ChanLabelIndex));'];
        case 'ICA'
            data_typeVal=2;
            chanlabel_callback=['for i=1:length(EEG.icaweights(:,1));IC(i).labels=sprintf(''%s%s'',''comp'',num2str(i));end;' ...
                '[ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel({IC.labels});' ...
                'set(findobj(gcbf,''tag'',''ChanIndexEdit''),''string'',vararg2str(ChanLabelIndex));'];
    end

    if isempty(EEG.chanlocs);
        disp('Labelling channels by number.');
        for i=1:EEG.nbchan;
            EEG.chanlocs(i).labels=num2str(i);
        end
    end
    
    Num2StrEvCount=0;
    for i=1:length(EEG.event);
        if isnumeric(EEG.event(i).type);
            Num2StrEvCount=Num2StrEvCount+1;
            EEG.event(i).type=num2str(EEG.event(i).type);
        end
    end
    
    if Num2StrEvCount>0;
        disp(sprintf('%s%s', num2str(Num2StrEvCount), 'event types converted from num2str'));
    end
    if ~isempty(EEG.event)
        tmpevent  = EEG.event;
        eventlist = vararg2str(unique({tmpevent.type}));
    else eventlist = '';
    end;
    
    % BUILD POP UP WINDOW ...
    results=inputgui( ...
        'geom', ...
        {...
        {7 26 [0 .2] [7 1]} ... %1
        {7 26 [0 .2] [6 1]} ... %2
        {7 26 [6 0] [1 1]} ... %3
        {7 26 [0 1] [6 1]} ... %4
        {7 26 [0 1.6] [6 1]} ... %5
        {7 26 [6 1.6] [1 1]} ... %6
        {7 26 [0 3] [6 1]} ... %7
        {7 26 [0 3.6] [6 1]} ... %8
        {7 26 [6 3.6] [1 1]} ... %9
        {7 26 [0 5] [6 1]} ... %10
        {7 26 [0 5.6] [6 1]} ... %11
        {7 26 [6 5.6] [1 1]} ... %12
        {7 26 [0 26] [7 1]} ... %12
        }, ...
        'uilist', ...
        {...
        ... %1
        {'Style', 'text', 'string', blanks(120)}, ...
        ... %2
        {'Style', 'text', 'string', 'Data signals to display as waveforms in eegplot figure axis:','FontWeight','bold'}, ...
        ... %3
        {'Style', 'popup', 'string', data_typeCell, 'value',data_typeVal,'tag', 'data_typePop'...
        'callback', ['switch get(gcbo,''value'');'...
        '    case 1;' ...
        '        set(findobj(gcbf,''tag'',''ChanLabelButton''),''callback'',' ...
        '            [''chan.labels=EEG.chanlocs.labels;' ...
        '            [ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel(chan.labels);' ...
        '             set(findobj(gcbf,''''tag'''',''''ChanIndexEdit''''),''''string'''',vararg2str(ChanLabelIndex))'']);' ...
        '        set(findobj(gcbf,''tag'',''ChanIndexEdit''),''string'',vararg2str(1:EEG.nbchan));' ...
        '    case 2;' ...
        '        set(findobj(gcbf, ''tag'', ''ChanLabelButton''), ''callback'',' ...
        '            [''for i=1:length(EEG.icaweights(:,1));IC(i).labels=sprintf(''''%s%s'''',''''comp'''',num2str(i));end;' ...
        '            [ChanLabelIndex,ChanLabelStr,ChanLabelCell]=pop_chansel({IC.labels});' ...
        '             set(findobj(gcbf,''''tag'''',''''ChanIndexEdit''''),''''string'''',vararg2str(ChanLabelIndex))'']);' ...
        '        set(findobj(gcbf,''tag'',''ChanIndexEdit''),''string'',vararg2str(1:length(EEG.icaweights(:,1))));' ...
        'end; clear tmpchanlocs;']}, ...
        ...
        ...
        {'Style', 'text', 'string', 'Channels to display in eegplot figure window:'}, ...
        ... %5
        {'Style', 'edit', 'string', chans,'tag', 'ChanIndexEdit'}, ...
        ... %6
        {'Style', 'pushbutton', 'string', '...', 'tag', 'ChanLabelButton',...
        'callback', chanlabel_callback}, ...
        {'Style', 'text', 'string', 'Event type(s) to display and edit:'}, ...
        ... %8
        {'Style', 'edit', 'string', eventlist, 'tag', 'PatIDEventTypeEdit'}, ...
        ... %9
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', ['tmpevent = EEG.event; [EventTypeIndex,EventTypeStr,EventTypeCell]=pop_chansel(unique({tmpevent.type})); clear tmpevent;' ...
        'set(findobj(gcbf, ''tag'', ''PatIDEventTypeEdit''), ''string'', vararg2str(EventTypeCell))']}, ...
        ... %10
        {'Style', 'text', 'string', 'mark types to include in initial manual rejection'}, ...
        ... %11
        {'Style', 'edit', 'string', '''manual''', 'tag', 'edt_marktype'}, ...
        ... %12
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', ['[marktypeIndex,marktypeStr,marktypeCell]=pop_chansel({EEG.marks.time_info.label});' ...
        'set(findobj(gcbf, ''tag'', ''edt_marktype''), ''string'', vararg2str(marktypeCell))']}, ...
        ... %13
        {'style','checkbox','string','Update VISED_CONFIG global variable','value',1}, ...
        }, ...
        'title', 'Select visual editing parameters -- pop_VisEd()', ...
        'eval',PropGridStr ...
        );
    
    global vecp;
    if ~isempty(vecp);
        vised_config=propgrid2visedconfig(vecp,vised_config);
    end
    clear global vecp
    
    % GET POP UP WINDOW RESULTS ...
    if isempty(results);com='';return;end
    
    vised_config.data_type=data_typeCell{results{1}};
    chans=results{2};
    event_type=results{3};
    vised_config.winrej_marks_labels=eval(['{',results{4},'}']);
    update_global=results{5};
    
end


%% UPDATE VISED_CONFIG GLOBAL VARIABLE IF REQUESTED...
if update_global;
    assignin('base', 'vised_config',vised_config);
end

%% ONCE ALL INPUTS ARE ESTABLISHED ...

% HANDLE chans
%chans=[];

if ~isempty(str2num(chans));
    chans=str2num(chans);
end

% HANDLE data_type
switch vised_config.data_type
    case 'EEG'
        if isempty(chans);
            chans=1:EEG.nbchan;
        end
        
        data=EEG.data(chans,:,:);
        
        for i=1:length(EEG.chanlocs);
            EEG.chanlocs(i).index=i;
        end
        VisEd.chan=EEG.chanlocs(chans);
        vised_config.eloc_file=VisEd.chan;
    case 'ICA'
        if isempty(chans);
            chans=1:min(size(EEG.icaweights));
        end
        
        eeglab_options; % changed from eeglaboptions 3/30/02 -sm
        if option_computeica
            data = EEG.icaact;
        else
            error('Activate ''precompute ICA activations'' in File->Memory and other options');
            data = (EEG.icaweights*EEG.icasphere)*reshape(EEG.data, length(EEG.icaweights(1,:)), EEG.trials*EEG.pnts);
            data = reshape( data, size(data,1), EEG.pnts, EEG.trials);
        end
        
        tmpdata=data(chans,:,:);
        data=[];
        data=tmpdata;
        
        for i=1:length(chans);
            VisEd.chan(i).labels=sprintf('%s%s','comp',num2str(chans(i)));
            VisEd.chan(i).flag=EEG.reject.gcompreject(chans(i))*-3;
            VisEd.chan(i).index=chans(i);
        end
        vised_config.eloc_file=VisEd.chan;
end

% HANDLE event_type...

if ischar(event_type);
    event_type=eval(['{',event_type,'}']);
end

j=0;
if isempty(event_type);
    VisEd.event = [];
else
    for i=1:length(EEG.event);
        if ~isempty(find(strcmp(EEG.event(i).type,event_type)));
            event=EEG.event(i);
            event.index=i;
            event.proc='none';
            j=j+1;
            VisEd.event(j)=event;
        end
    end
end

try vised_config.tmp_events=VisEd.event; catch, vised_config.tmp_events = [];end

if ~isempty(vised_config.quick_evtmk)%overwrites vised_config.altselectcommand
    vised_config.altselectcommand={ ['ve_edit(EEG,''quick_evtmk'',''', ...
        vised_config.quick_evtmk, ...
        ''');'] ...
        've_eegplot(''defmotioncom'', gcbf);' '' };
end

switch vised_config.quick_evtrm
    case 'ext_press'
        vised_config.extselectcommand={ ['ve_edit(EEG,''quick_evtrm'',''on'');'] ...
            've_eegplot(''defmotioncom'', gcbf);' '' };
    case 'alt_press'
        vised_config.altselectcommand={ ['ve_edit(EEG,''quick_evtrm'',''on'');'] ...
            've_eegplot(''defmotioncom'', gcbf);' '' };
end

switch vised_config.quick_chanflag
    case 'ext_press'
        vised_config.extselectcommand={ ['ve_edit(EEG,''quick_chanflag'',''manual'');'] ...
            've_eegplot(''defmotioncom'', gcbf);' '' };
    case 'alt_press'
        vised_config.altselectcommand={ ['ve_edit(EEG,''quick_chanflag'',''manual'');'] ...
            've_eegplot(''defmotioncom'', gcbf);' '' };
end


vised_config.time_marks_struct=tmp.time_marks_struct;
%% PREPARE VARIABLES FOR EEGPLOT ...
rejeegplot=[];
if ~isempty(vised_config.winrej_marks_labels)
    if EEG.trials > 1
        flags=marks_label2index(vised_config.time_marks_struct,vised_config.winrej_marks_labels,'flags');
        j=0;
        for i=1:EEG.trials;
            if any(flags(i));
                j=j+1;
                rejeegplot(j,1)=(EEG.pnts*i)-(EEG.pnts-1);
                rejeegplot(j,2)=(EEG.pnts*i);
                rejeegplot(j,3:5)=vised_config.wincolor;
                rejeegplot(j,6:EEG.nbchan+5)=zeros(1,EEG.nbchan);
            end
        end
    else
        rejeegplot=marks_label2index(vised_config.time_marks_struct,vised_config.winrej_marks_labels,'bounds');
    end
end
vised_config.winrej=rejeegplot;

switch vised_config.data_type
    case 'EEG'
        if isfield(EEG.chanlocs,'badchan');
            disp('merging badchan field into marks structure manual field...');
            chflags=any([EEG.marks.chan_info(1).flags,[EEG.chanlocs.badchan]']);
            EEG.marks.chan_info(1).flags=chflags;
        end
        if isempty(vised_config.chan_marks_struct);
            vised_config.chan_marks_struct=EEG.marks.chan_info;
        end
    case 'ICA'
        %if isempty(vised_config.chan_marks_struct);
        %end
        if isempty(vised_config.chan_marks_struct);
            for i=1:length(EEG.marks.comp_info);
                if isempty(EEG.marks.comp_info(i).flags);
                    EEG.marks.comp_info(i).flags=zeros(min(size(EEG.icaweights)),1);
                end
            end
            vised_config.chan_marks_struct=EEG.marks.comp_info;
        end
end

for i=1:length(vised_config.chan_marks_struct);
    vised_config.chan_marks_struct(i).flags=vised_config.chan_marks_struct(i).flags(chans);
end

if isempty(str2num(vised_config.children))
    try vised_config.children=findobj('tag',vised_config.children);
    catch, disp('the children tag does not exist... figure will have no child')
    end
else
    vised_config.children=str2num(vised_config.children);
end

%% COLLECT EEGPLOT_OPTIONS AND EXECUTE CALL TO EEGPLOT...
vararg_cell=object2varargin(vised_config,vised_option_names);

% prepend srate.. it always needs to be included...
vararg_cell={'srate',srate,vararg_cell{:}};

% rename 'tmp_events' to 'events' if occurs. 
for i=1:length(vararg_cell);
    if ischar(vararg_cell{i}) && strcmp(vararg_cell{i},'tmp_events');
        vararg_cell{i}='events';
    end
end

ve_eegplot(data, vararg_cell{:});

temp_config = init_vised_config;
keywords = fieldnames(vised_config);
vararg_str = '';
for i=1:length(keywords);
     curr_field = eval(['vised_config.',keywords{i}]);
     dflt_field = [];
     if isfield(temp_config,eval('keywords{i}'));
         dflt_field = eval(['temp_config.',keywords{i}]);
     end
     if ischar(curr_field);
         if ~strcmp(curr_field,dflt_field);
             quote_inds = strfind(curr_field,'''');
             if length(quote_inds)==1;
                curr_field = [curr_field(1:quote_inds) '''' curr_field(quote_inds+1:end)];
             elseif length(quote_inds)>1;
                for j=1:length(quote_inds);
                    curr_field = [curr_field(1:quote_inds(j)+j-1) '''' curr_field(j+quote_inds(j):end)];
                end
             end
             vararg_str = strcat(vararg_str,',','''',keywords{i},'''',',','''',curr_field,'''');
         end
     elseif iscell(curr_field);
         if ~isempty(setdiff(curr_field,dflt_field));
             tf = transpose(curr_field);
             vararg_str = strcat(vararg_str,',','''',keywords{i},'''',',{');
             for t=1:length(tf);
                 quote_inds = strfind(tf{t},'''');
                 if length(quote_inds)==1;
                     tf{t} = [tf{t}(1:quote_inds) '''' tf{t}(quote_inds+1:end)];
                 elseif length(quote_inds)>1;
                     for j=1:length(quote_inds);
                         tf{t} = [tf{t}(1:quote_inds(j)+j-1) '''' tf{t}(j+quote_inds(j):end)];
                     end
                 end
                 vararg_str = strcat(vararg_str,'''',tf{t},'''',';');
                 if t==length(tf);
                     vararg_str = vararg_str(1:end-1);
                 end
             end
             vararg_str = strcat(vararg_str,'}');
         end
     elseif isnumeric(curr_field);
         if isempty(dflt_field);
            dflt_field = 0;
         end
         if ~all(size(curr_field)==[1,1]);
             continue;
         end
         if curr_field~=dflt_field;
             vararg_str = strcat(vararg_str,',','''',keywords{i},'''',',',num2str(curr_field));
         end
     end
end
vararg_str = vararg_str(2:end); % remove leading comma
%% RETURN COMMAND AND EVALUATE CALL TO VISED
com=sprintf('EEG = pop_vised(EEG,''pop_gui'',''off'',%s);',vararg_str);
