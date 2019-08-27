function ve_edit(varargin)

%% ONLY FOLLOW THROUGH IF THE CURRENTOBJ IS NOT ESPACING OR EPOSITION...

% Get the figure and axis userdata...
udf = get(gcf, 'userdata');
uda = get(gca, 'userdata');

h_eegaxis = findobj('tag', 'eegaxis', 'parent', gcf);
h_espacing = findobj('tag', 'ESpacing', 'parent', gcf);
h_eposition = findobj('tag', 'EPosition', 'parent', gcf);

current_obj = get(gcf, 'CurrentObject');

if ~isempty(current_obj) && ((current_obj == h_espacing) || (current_obj == h_eposition))
    return
end

%% HANDLE THE INPUTS...
options = varargin;
for index = 1:length(options)
    if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = {options{index}}; end;
end;

g = [];
if ~isempty(varargin)
    g = struct(options{:});
end;

try g.quick_evtmk; catch
    try g.quick_evtmk = g.qem; catch, g.quick_evtmk = ''; end; end;

try g.quick_evtrm; catch
    try g.quick_evtrm = g.qer; catch, g.quick_evtrm = 'off'; end; end;

try g.quick_chanflag; catch
    try g.quick_chanflag = g.qcf; catch, g.quick_chanflag = ''; end; end;

try g.select_mark; catch
    try g.select_mark = g.sm; catch, g.select_mark = 'off'; end; end;

try g.add_winrej_mark; catch
    try g.add_winrej_mark = g.awm; catch, g.add_winrej_mark = ''; end; end;
try g.rm_winrej_mark; catch
    try g.rm_winrej_mark = g.rwm; catch, g.rm_winrej_mark = ''; end; end;

try g.add_page_mark; catch
    try g.add_page_mark = g.apm; catch, g.add_page_mark = ''; end; end;
try g.rm_page_mark; catch
    try g.rm_page_mark = g.rpm; catch, g.rm_page_mark = ''; end; end;

try g.page_forward; catch
    try g.page_forward = g.pf; catch, g.page_forward = 'off'; end; end;

try g.data_move; catch
    try g.data_move = g.dm; catch, g.data_move = 'off'; end; end;

%% Store "tmppos" in the "g" structures...
g.tmppos = get(h_eegaxis, 'currentpoint');

%% Handle the index of the events...
if ~isfield(udf.events, 'index')
    indexes = num2cell(1:numel(udf.events));
    [udf.events(:).index] = deal(indexes{:});
    [udf.events.proc] = deal('none');
end

%% Define relative starting point for figure window latencies: "EEG.eventedit.WinStartPnt"
if size(uda, 3) == 1; % define WinStartPt. data point at wich current display window begins.
    g.eventedit.WinStartPnt = udf.time * udf.srate;
    g.eventedit.EpochIndex = 1;
else
    g.eventedit.WindowIndex = udf.time + 1;
    g.eventedit.WinStartPnt = g.eventedit.WindowIndex * size(uda, 2) - (size(uda, 2) - 1);
    g.eventedit.EpochIndex = ceil((g.tmppos(1, 1) + g.eventedit.WinStartPnt)/size(uda, 2));
end;

g.eventedit.PosLat = round(g.tmppos(1, 1)+g.eventedit.WinStartPnt);


%% Identify selected channel.
% By default use the 'Eelec' tex display of eegplot.
tmpChanIndex = strmatch(get(findobj(gcf, 'Tag', 'Eelec'), 'string'), ...
    {udf.eloc_file.labels}, 'exact');
if length(tmpChanIndex) == 1;
    g.eventedit.ChanIndex = tmpChanIndex;
else
    % Otherwise calculate ChanIndex from tmppos.
    nWin = (udf.chans - udf.dispchans) + 1;
    stepWin = 1 / nWin;
    if udf.dispchans == udf.chans;
        curWinStrt = 0;
    else
        curWinStrt = floor((1 - get(findobj('tag', 'eegslider'), ...
            'value'))/stepWin);
    end
    curWinEnd = curWinStrt + udf.dispchans;
    
    YIndex = floor((tmppos(1, 2) / (1 / (udf.dispchans + 1)))-.5);
    g.eventedit.ChanIndex = (curWinEnd - YIndex);
    
    if g.eventedit.ChanIndex == 0;
        g.eventedit.ChanIndex = 1;
    end
    if g.eventedit.ChanIndex > size(uda, 1);
        g.eventedit.ChanIndex = size(uda, 1);
    end
end
clear tmpChanIndex

%% Check for event selection.
pntdist = ceil((udf.winlength * udf.srate)*0.002);
if isfield(g.eventedit, 'SelEventStruct');
    g = rmfield(g.eventedit, 'SelEventStruct');
end
j = 0;
for i = 1:length(udf.events);
    if abs(udf.events(i).latency-g.eventedit.PosLat) < pntdist;
        j = j + 1;
        g.eventedit.SelEventStruct(j).index = i;
        g.eventedit.SelEventStruct(j).dist = abs(udf.events(i).latency - ...
            round(g.tmppos(1, 1)+g.eventedit.WinStartPnt));
        g.eventedit.SelEventStruct(j).type = udf.events(i).type;
        g.eventedit.SelEventStruct(j).latency = udf.events(i).latency;
    end
end

%% HANDLE SELECT_MARK...
if strcmp(g.select_mark, 'on');
    ylims = get(gca, 'YLim');
    cxpnt = g.eventedit.WinStartPnt + round(g.tmppos(1, 1));
    
    inter_time_mark_offset = diff(ylims) * udf.inter_mark_int;
    time_marks_offset = diff(ylims) * udf.marks_y_loc;
    for tmi = 1:length(udf.time_marks_struct);
        for i = 1:length(time_marks_offset)
            l = ylims(1) + inter_time_mark_offset * tmi + ...
                time_marks_offset(i) - inter_time_mark_offset * ...
                length(udf.time_marks_struct);
            h = ylims(1) + inter_time_mark_offset * tmi + ...
                time_marks_offset(i) + inter_time_mark_offset - ...
                inter_time_mark_offset * length(udf.time_marks_struct);
            
            if g.tmppos(1, 2) > l && g.tmppos(1, 2) < h ...
                    && udf.time_marks_struct(tmi).flags(cxpnt)
                for pi = 1:cxpnt - 1
                    if udf.time_marks_struct(tmi).flags(cxpnt-pi) == 0 ...
                            || cxpnt - pi == 0
                        bnd(1) = cxpnt - (pi - 1);
                        break
                    end
                end
                for pi = 1:size(uda, 2) - cxpnt;
                    if udf.time_marks_struct(tmi).flags(cxpnt+pi) == 0 ...
                            || cxpnt + pi == size(uda, 2)
                        bnd(2) = cxpnt + pi;
                        break
                    end
                end
                if size(udf.winrej, 2) == 2;
                    udf.winrej(size(udf.winrej, 1)+1, :) = bnd;
                else
                    udf.winrej(size(udf.winrej, 1)+1, 1:2) = bnd;
                    udf.winrej(size(udf.winrej, 1)+1, 3:5) = udf.wincolor;
                    udf.winrej(size(udf.winrej, 1)+1, 6:size(udf.winrej, 2)) = zeros(1, size(udf.winrej, 2)-5);
                end
                set(gcf, 'userdata', udf);
                ve_eegplot('drawp', 0);
            end
        end
    end
    return
end

%% HANDLE ADD/REMOVE MARKS...
if ~isempty(g.add_winrej_mark) || ~isempty(g.add_page_mark) || ~isempty(g.rm_winrej_mark) || ~isempty(g.rm_page_mark)
    cxpnt = g.eventedit.WinStartPnt + round(g.tmppos(1, 1));
    
    %find mark index
    if ~isempty(g.add_winrej_mark)
        mark_label = g.add_winrej_mark;
    elseif ~isempty(g.add_page_mark)
        mark_label = g.add_page_mark;
    elseif ~isempty(g.rm_winrej_mark);
        mark_label = g.rm_winrej_mark;
    elseif ~isempty(g.rm_page_mark);
        mark_label = g.rm_page_mark;
    end
    
    if strcmp(mark_label, 'pop_select')
        label_index = pop_chansel({udf.time_marks_struct.label});
    else
        label_index = find(strcmp(mark_label, {udf.time_marks_struct.label}));
    end
    if isempty(label_index);
        tmp_marks_struct.time_info = udf.time_marks_struct;
        tmp_marks_struct = pop_marks_add_label(tmp_marks_struct, 'info_type', 'time_info', ...
            'label', mark_label, ...
            'action', 'add', ...
            'message', 'Fill in the missing information for the mark that you are adding.');
        udf.time_marks_struct = tmp_marks_struct.time_info;
        label_index = length(udf.time_marks_struct);
        
    end
    
    if ~isempty(g.add_page_mark)
        udf.time_marks_struct(label_index).flags(g.eventedit.WinStartPnt ...
            +1:g.eventedit.WinStartPnt+(udf.winlength * udf.srate)) = 1;
        udf.time_marks_struct(label_index).flags(g.eventedit.WinStartPnt ...
            + 1:g.eventedit.WinStartPnt+(udf.winlength * udf.srate)) = 9;
    end
    
    for wi = 1:size(udf.winrej, 1)
        if cxpnt > udf.winrej(wi, 1) && cxpnt < udf.winrej(wi, 2)
            if ~isempty(g.add_winrej_mark)
                
                udf.time_marks_struct(label_index).flags(round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2))) = 1;
                
                if strcmp(g.data_move, 'on');
                    if ~isfield(udf, 'urdata')
                        udf.urdata = uda;
                    end
                    if isfield(udf, 'data2');
                        uda(:, (round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2)))) = udf.data2(:, (round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2))));
                        set(gca, 'userdata', uda);
                    end
                end
            end
            if ~isempty(g.rm_winrej_mark)
                udf.time_marks_struct(label_index).flags(round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2))) = 0;
                if strcmp(g.data_move, 'on') && isfield(udf, 'urdata');
                    uda(:, (round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2)))) = udf.urdata(:, (round(udf.winrej(wi, 1)):round(udf.winrej(wi, 2))));
                    set(gca, 'userdata', uda);
                end
            end
        end
    end
    set(gcf, 'userdata', udf);
        
    if (isfield(g,'awm') && strcmp(g.awm,'manual')) || (isfield(g,'rwm') && strcmp(g.rwm,'manual'));
	
        figh = gcf; % figure handle
        if strcmp(get(figh,'tag'),'dialog')
            figh = get(figh,'UserData');
        end
        ax0 = findobj('tag','backeeg','parent',figh); % axes handle
        ax1 = findobj('tag','eegaxis','parent',figh); % axes handle

        data = get(ax1,'UserData');
        ESpacing = findobj('tag','ESpacing','parent',figh);   % ui handle
        EPosition = findobj('tag','EPosition','parent',figh); % ui handle
        if udf.trialstag(1) == -1
            udf.time    = str2num(get(EPosition,'string'));  
        else
            udf.time    = str2num(get(EPosition,'string'));
            udf.time    = udf.time - 1;
        end; 
        udf.spacing = str2num(get(ESpacing,'string'));

         if udf.trialstag ~= -1 % time in second or in trials
            multiplier = udf.trialstag;	
         else
            multiplier = udf.srate;
         end;		

        % Update edit box
        % ---------------
        udf.time = max(0,min(udf.time,ceil((udf.frames-1)/multiplier)-udf.winlength));
        if udf.trialstag(1) == -1
            set(EPosition,'string',num2str(udf.time)); 
        else 
            set(EPosition,'string',num2str(udf.time+1)); 
        end; 
        set(figh, 'userdata', udf);

        lowlim = round(udf.time*multiplier+1);
        highlim = round(min((udf.time+udf.winlength)*multiplier+2,udf.frames));
        low_high_range = lowlim:highlim;
        zlowhigh = zeros(1,length(low_high_range));
        
        ylims=get(gca,'YLim');
        inter_time_mark_offset=diff(ylims)*udf.inter_mark_int;
        time_marks_offset=diff(ylims)*udf.marks_y_loc;

        % plot time_info flags.
        cmap=[];  
        j=0;

        cflags=double([udf.time_marks_struct(1).flags(lowlim:highlim);udf.time_marks_struct(1).flags(lowlim:highlim)]);
        cdat=cflags;

        cdat=udf.marks_col_int*round(cflags/udf.marks_col_int);
        tmp_cdat=cdat;
        uval=unique(cdat);
        for ci=1:length(uval);
            tmp_cdat(find(cdat==uval(ci)))=ci+j-1;
            cmap(ci+j,:)=ones(1,3)-((ones(1,3)-udf.time_marks_struct(1).color)*uval(ci));
        end
        j=j+length(uval);
        cdat=tmp_cdat;

        for i=1:length(time_marks_offset)
            delete (findobj('tag','mark_manual'));
            sh=surf(1:size(cflags,2), ...
                [ylims(1)+inter_time_mark_offset*1+(time_marks_offset(i))-(inter_time_mark_offset*length(udf.time_marks_struct)), ...
                 ylims(1)+inter_time_mark_offset*1+(time_marks_offset(i))+inter_time_mark_offset-(inter_time_mark_offset*length(udf.time_marks_struct))], ...
                cflags, ...
                'CData',cdat, ...
                'LineStyle','none','tag',['mark_' udf.time_marks_struct(1).label]);
            alpha(sh,udf.marks_col_alpha);
        end
        return
    end
    
    if strcmp(g.page_forward, 'off');
        ve_eegplot('drawp', 0)
    else
        ve_eegplot('drawp', 4)
    end
    return
end

pop_ve_edit(g);
