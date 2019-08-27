function [EEG,com]=pop_marks_flag_gap(EEG,mark_label,crit_dur_ms,new_label,new_color,varargin)

com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            


% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_marks_flag_gap;
	return;
end;	

g=struct(varargin{:});

try g.exact; catch; g.exact = 'on';end
try g.offsets; catch; g.offsets = [0 0];end
try g.ref_point; catch; g.ref_point = 1;end
ref_points_cell={'both','first','second'};
try g.invert_flags; catch; g.invert_flags = 'off';end
try g.critdir; catch; g.critdir = 'max';end;

if ~isfield(EEG,'marks');
    if isempty(EEG.icaweights);
        EEG.marks=marks_init(size(EEG.data));
    else
        EEG.marks=marks_init(size(EEG.data),min(size(EEG.icaweights)));
    end
end

% pop up window
% -------------
if nargin < 5

    results=inputgui( ...
    {[4 2] [4 1 1] 1 [2 2 .8 1.2] [2 2 2] [2 2 2] [2 2 2]}, ...
    {...
        {'Style', 'text', 'string', ['Mark labels to consider for flag gaps',blanks(0)]}, ...
        {}, ...
...
        {'Style', 'edit', 'string', vararg2str({EEG.marks.time_info.label}), 'tag', 'edt_ft'}, ...
        {'Style', 'pushbutton', 'string', '...', ...
        'callback', ['[flagtype_ind,flagtype_str,flagtype_cell]=pop_chansel({EEG.marks.time_info.label});' ...
        'set(findobj(gcbf, ''tag'', ''edt_ft''), ''string'', vararg2str(flagtype_cell))']}, ...
        {'Style','checkbox','string','Exact label','value',1}, ...
...
        {}, ...
...
        {'Style','text','string','Critical inter-flag gap [ms]'}, ...
        {'Style','edit','string','3000','tag','edt_ifg'}, ...
        {'Style','text','string','Offsets [ms]'}, ...
        {'Style','edit','string','[0 0]','tag','edt_mo'}, ...
...
        {'Style','text','string','Gap mark reference points'}, ...
        {'Style','popup','string',ref_points_cell,'value',1}, ...
        {'Style','checkbox','string','Invert flags'}, ...
...
        {'Style','text','string','New mark label'}, ...
        {'Style','edit','string','flag_gap','tag','edt_nfl'}, ...
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
    'pophelp(''pop_mark_flag_gap'');', 'mark periods of time between neighbouring flags -- pop_mark_flag_gap()' ...
    );

    eval(['mark_label = {',results{1},'};']);
    if results{2}==0;
        g.exact='off';
    end
    crit_dur_ms         = str2num(results{3}); 
    g.offsets           = str2num(results{4});
         
    %if results{5}~=1;
    g.ref_point=ref_points_cell{results{5}};
    %end
    if results{6}==1;
        g.invert_flags='on';
    end
    new_label           = results{7};
    new_color           = str2num(results{8});

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
com = ['EEG = pop_marks_flag_gap(EEG,{',vararg2str(mark_label),'},',num2str(crit_dur_ms),',''',new_label,''',[',num2str(new_color),']',options,');'];

if isempty(mark_label);
    mark_label={EEG.marks.time_info.label};
end

if strcmp(g.exact,'off');
    mark_label=marks_match_label(mark_label,unique({EEG.marks.time_info.label}));
end


crit_dur_pnts=ceil(crit_dur_ms/(1000/EEG.srate));
offset_pnts=ceil(g.offsets/(1000/EEG.srate));

flagbnd=marks_label2index(EEG.marks.time_info,mark_label,'bounds');

gapflags=zeros(1,EEG.pnts);
gapbound=[];

if ~isempty(flagbnd);
    j=0;
    switch g.ref_point;
        case 'both'
            for i=1:size(flagbnd,1);
                if i==1; %check distance from beginning of recording...
                    if flagbnd(i,1)>1&&flagbnd(i,1)<crit_dur_pnts;
                        j=j+1;
                        gapbound(j,1)=1;
                        gapbound(j,2)=flagbnd(i,1)+offset_pnts(2);
                    end
                else
                    if flagbnd(i,1)-flagbnd(i-1,2)<crit_dur_pnts; %check distacnce between flag bounds...
                        j=j+1;
                        gapbound(j,1)=flagbnd(i-1,2)+offset_pnts(1);
                        gapbound(j,2)=flagbnd(i,1)+offset_pnts(2);
                    end
                end
            end
            if EEG.pnts-flagbnd(i,2)>0&&EEG.pnts-flagbnd(i,2)<crit_dur_pnts; % check distance from the end of recording...
                j=j+1;
                gapbound(j,1)=flagbnd(i,2)+offset_pnts(1);
                gapbound(j,2)=EEG.pnts;
            end
       case 'first'
            for i=1:size(flagbnd,1);
                if i==1; %check distance from beginning of recording...
                    if flagbnd(i,1)>1&&flagbnd(i,1)<crit_dur_pnts;
                        j=j+1;
                        gapbound(j,1)=1+offset_pnts(1);
                        gapbound(j,2)=1+offset_pnts(2);
                    end
                else
                    if flagbnd(i,1)-flagbnd(i-1,2)<crit_dur_pnts; %check distacnce between flag bounds...
                        j=j+1;
                        gapbound(j,1)=flagbnd(i-1,2)+offset_pnts(1);
                        gapbound(j,2)=flagbnd(i-1,2)+offset_pnts(2);
                    end
                end
            end
            if EEG.pnts-flagbnd(i,2)>0&&EEG.pnts-flagbnd(i,2)<crit_dur_pnts; % check distance from the end of recording...
                j=j+1;
                gapbound(j,1)=flagbnd(i,2)+offset_pnts(1);
                gapbound(j,2)=flagbnd(i,2)+offset_pnts(2);
            end
        case 'second'
            for i=1:size(flagbnd,1);
                if i==1; %check distance from beginning of recording...
                    if flagbnd(i,1)>1&&flagbnd(i,1)<crit_dur_pnts;
                        j=j+1;
                        gapbound(j,1)=flagbnd(i,1)+offset_pnts(1);
                        gapbound(j,2)=flagbnd(i,1)+offset_pnts(2);
                    end
                else
                    if flagbnd(i,1)-flagbnd(i-1,2)<crit_dur_pnts; %check distacnce between flag bounds...
                        j=j+1;
                        gapbound(j,1)=flagbnd(i,1)+offset_pnts(1);
                        gapbound(j,2)=flagbnd(i,1)+offset_pnts(2);
                    end
                end
            end
            if EEG.pnts-flagbnd(i,2)>0&&EEG.pnts-flagbnd(i,2)<crit_dur_pnts; % check distance from the end of recording...
                j=j+1;
                gapbound(j,1)=EEG.pnts+offset_pnts(1);
                gapbound(j,2)=EEG.pnts+offset_pnts(2);
            end
    end
    
    
    if ~isempty(gapbound);
        if gapbound(1,1)<1;gapbound(1,1)=1;end
        if gapbound(size(gapbound,1),2)>EEG.pnts;gapbound(size(gapbound,1),2)=EEG.pnts;end
        gapflags=marks_bound2flag(gapbound,gapflags);
    end
end

EEG.marks=marks_add_label(EEG.marks,'time_info', ...
	{new_label,new_color,gapflags});
