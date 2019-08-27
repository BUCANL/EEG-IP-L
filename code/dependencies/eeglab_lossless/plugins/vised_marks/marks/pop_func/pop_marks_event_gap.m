function [EEG,com]=pop_marks_event_gap(EEG,event_type,crit_dur_ms,new_label,new_color,varargin)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_marks_event_gap;
	return;
end;	

g=struct(varargin{:});

try g.exact; catch; g.exact = 'on';end
try g.offsets; catch; g.offsets = [0 0];end
try g.ref_point; catch; g.ref_point = 1;end
ref_points_cell={'both','first','second'};

try g.invert_flags; catch; g.invert_flags = 'off';end
try g.critdir; catch; g.critdir='min';end
critdir_cell={'max','min'};

try g.interval; catch; g.interval='off';end
if strcmp(g.interval,'off');
    interval_val=0;
else
    interval_val=1;
end

% pop up window
% -------------
if nargin < 5

    results=inputgui( ...
    {[4 2] [4 1 1] 1 1 [2 1 1 .8 1.2] [2 1 1 2] [2 2 2] [2 2 2]}, ...
    {...
        {'Style', 'text', 'string', ['Event types to consider for gaps',blanks(0)]}, ...
        {}, ...
...
        {'Style', 'edit', 'string', vararg2str(unique({EEG.event.type})), 'tag', 'edt_ft'}, ...
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', ['[eventtype_ind,eventtype_str,eventtype_cell]=pop_chansel(unique({EEG.event.type}));' ...
        'set(findobj(gcbf, ''tag'', ''edt_ft''), ''string'', vararg2str(eventtype_cell))']}, ...
        {'Style','checkbox','string','Exact label'}, ...
...
        {'Style','checkbox','string','{start stop} interval event types','value',interval_val,...
        'callback',['if get(gcbo,''value'')', ...
                    '   set(findobj(gcbf,''tag'',''cdt''),''enable'',''off'');', ...
                    '   set(findobj(gcbf,''tag'',''cdp''),''enable'',''off'');', ...
                    '   set(findobj(gcbf,''tag'',''edt_ifg''),''enable'',''off'');', ...
                    'else;', ...
                    '   set(findobj(gcbf,''tag'',''cdt''),''enable'',''on'');' ...
                    '   set(findobj(gcbf,''tag'',''cdp''),''enable'',''on'');' ...
                    '   set(findobj(gcbf,''tag'',''edt_ifg''),''enable'',''on'');' ...
                    'end']}, ...
...
        {}, ...
...
        {'Style','text','string','Critical inter-flag gap [ms]','tag','cdt'}, ...
        {'Style','popup','string',critdir_cell,'tag','cdp'}, ...
        {'Style','edit','string','3000','tag','edt_ifg'}, ...
        {'Style','text','string','Offsets [ms]'}, ...
        {'Style','edit','string','[0 0]','tag','edt_mo'}, ...
...
        {'Style','text','string','Gap mark reference points'}, ...
        {'Style','popup','string',ref_points_cell,'value',1}, ...
        {'Style','checkbox','string','Invert flags'}, ...
        {}, ...
...
        {'Style','text','string','New mark label'}, ...
        {'Style','edit','string','event_gap','tag','edt_nfl'}, ...
        {}, ...
...        
        {'Style','text','string','New mark color ([R G B])'}, ...
        {'Style','edit','string','.2 .2 .2','tag','edt_nmc', ...
        'callback',[ 'set(findobj(gcbf,''tag'',''but_nmc''),' ...
                    '''backgroundcolor'',str2num(get(gcbo,''string'')));']}, ...
        {'Style', 'pushbutton', 'string', '','backgroundcolor',[.2 .2 .2], 'tag', 'but_nmc', ...
        'callback', [ 'tmpcolor = uisetcolor(''select flag color''); if length(tmpcolor) ~= 1,' ...
        'new_color=tmpcolor; set(gcbo, ''backgroundcolor'', tmpcolor);', ...
        'set(findobj(gcbf,''tag'',''edt_nmc''),''string'',num2str(tmpcolor));',...
        'end; clear tmpcolor;'] }
    }, ...
    'pophelp(''pop_mark_event_gap'');', 'mark periods of time between event sequences -- pop_mark_event_gap()' ...
    );

    if isempty(results);return;end

    eval(['event_type = {',results{1},'};']);
    if results{2}==0;
        g.exact='off';
    end
    if results{3};g.interval='on';
    else g.interval='off';end
    
    g.critdir           = critdir_cell{results{4}};
    crit_dur_ms         = str2num(results{5}); 
    g.offsets           = str2num(results{6});
         
    g.ref_point=ref_points_cell{results{7}};

    if results{8}==1;
        g.invert_flags='on';
    end
    new_label           = results{9};
    new_color           = str2num(results{10});

end

options='';
if ~strcmp(g.exact,'on');
    options=[options,',''exact'',''off'''];
end
if g.offsets~=zeros(1,2);
    options=[options,',''offsets'',[',num2str(g.offsets),']'];
end
if g.ref_point~=1;
    options=[options,',''ref_point'',''',g.ref_point,''''];
end
if ~strcmp(g.invert_flags,'off');
    options=[options,',''invert_flags'',''on'''];
end


% create the string command
% -------------------------
com = ['EEG = pop_marks_event_gap(EEG,{',vararg2str(event_type),'},',num2str(crit_dur_ms),',''',new_label,''',[',num2str(new_color),']',options,');'];

if isempty(event_type);
    event_type=unique({EEG.event.type});
end


offset_pnts=ceil(g.offsets/(1000/EEG.srate));

if ischar(event_type);
    event_type=cellstr(event_type);
end

bounds=[];
flags=[];

%% GAP DETECTION OR INTERVAL DETECTION...
if strcmp(g.interval,'off'); %gap detection...

    crit_dur_pnts=ceil(crit_dur_ms/(1000/EEG.srate));
    crit_dur_pnts=ceil(crit_dur_ms/(1000/EEG.srate));
    
    j=0;
    for ei=1:length(EEG.event);
        for eti=1:length(event_type);
            switch g.exact
                case 'on'
                    if strcmp(EEG.event(ei).type,event_type{eti});
                        j=j+1;
                        event_latency(j)=EEG.event(ei).latency;
                    end
                case 'off'
                    if ~isempty(strfind(EEG.event(ei).type,event_type{eti}));
                        j=j+1;
                        event_latency(j)=EEG.event(ei).latency;
                    end
            end
        end
    end
    event_latency=sort(event_latency);
    
    if strcmp(g.critdir,'max')
        dirsign='>';
    else
        dirsign='<';
    end
    
    j=0;
    for i=1:length(event_latency);
        if i==1;
            if eval(['event_latency(i)',dirsign,'crit_dur_pnts;']);
                switch g.ref_point
                    case 'both'
                        j=j+1;
                        bounds(j,1)=1;
                        bounds(j,2)=ceil(event_latency(i))+offset_pnts(2);
                    case 'second'
                        j=j+1;
                        bounds(j,1)=ceil(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i))+offset_pnts(2);
                end
            end
            if eval(['event_latency(i+1)-event_latency(i)',dirsign,'crit_dur_pnts;']);
                switch g.ref_point
                    case 'both'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i+1))+offset_pnts(2);
                    case 'first'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i))+offset_pnts(2);
                    case 'second'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i+1))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i+1))+offset_pnts(2);
                end
            end
        elseif i<length(event_latency);
            if eval(['event_latency(i+1)-event_latency(i)',dirsign,'crit_dur_pnts;']);
                switch g.ref_point
                    case 'both'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i+1))+offset_pnts(2);
                    case 'first'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i))+offset_pnts(2);
                    case 'second'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i+1))+offset_pnts(1);
                        bounds(j,2)=ceil(event_latency(i+1))+offset_pnts(2);
                end
            end
        else
            if eval(['EEG.pnts-event_latency(i)',dirsign,'crit_dur_pnts;']);
                switch g.ref_point
                    case 'both'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=EEG.pnts;
                    case 'first'
                        j=j+1;
                        bounds(j,1)=floor(event_latency(i))+offset_pnts(1);
                        bounds(j,2)=EEG.pnts;
                end
            end
        end
    end
    
else %g.interval

    if length(event_type)~=2
        disp(['For interval marking there needs to be two event types {begin end}, Doing nothing...']);
        return
    end
    
    j=0;
    k=0;
    for i=1:length(EEG.event);
        switch g.exact
            case 'on'
                if strcmp(EEG.event(i).type,event_type{1});
                    j=j+1;
                    event_start_latency(j)=EEG.event(i).latency;
                end
                if strcmp(EEG.event(i).type,event_type{2});
                    k=k+1;
                    event_end_latency(k)=EEG.event(i).latency;
                end
            case 'off'
                if ~isempty(strfind(EEG.event(i).type,event_type{1}));
                    j=j+1;
                    event_start_latency(j)=EEG.event(i).latency;
                end
                if ~isempty(strfind(EEG.event(i).type,event_type{2}));
                    k=k+1;
                    event_end_latency(k)=EEG.event(i).latency;
                end
        end
    end
    event_start_latency=sort(event_start_latency);
    event_end_latency=sort(event_end_latency);
        
    if length(event_start_latency)==length(event_end_latency);
        switch g.ref_point
            case 'both'
                b1=event_start_latency;
                b2=event_end_latency;
            case 'first'
                b1=event_start_latency;
                b2=event_start_latency;
            case 'second'
                b1=event_end_latency;
                b2=event_end_latency;
        end
        for i=1:length(event_start_latency);
            bounds(i,1)=floor(b1(i)+offset_pnts(1));
            bounds(i,2)=ceil(b2(i)+offset_pnts(2));
        end
    else
        disp('number of start events does not match the number of end events... doing nothing');
        return
    end
    
%    flags=zeros(1,EEG.pnts);
    
%    if ~isempty(bounds);
%        for i=1:size(bounds,1);
%            flags(bounds(i,1):bounds(i,2))=1;
%        end
%    end
    
%    if strcmp(g.invertflags,'on');
%        flags=~flags;
%    end
end

%% BUILD MARKS
flags=zeros(1,EEG.pnts);

if ~isempty(bounds);
    if bounds(1,1)<1;bounds(1,1)=1;end
    if bounds(size(bounds,1),2)>EEG.pnts;bounds(size(bounds,1),2)=EEG.pnts;end
    flags=marks_bound2flag(bounds,flags);
end

if strcmp(g.invert_flags,'on');
    flags=~flags;
end

if ~isfield(EEG,'marks');
    if isempty(EEG.icaweights)
        EEG.marks=marks_init(size(EEG.data));
    else
        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));
    end
end

EEG.marks = marks_add_label(EEG.marks,'time_info', ...
	{new_label,new_color,flags});
