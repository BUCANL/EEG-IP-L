function marks_struct = marks_add_label(marks_struct,info_type,mark_prop)

if isempty(marks_struct)
    nflags=0;
else
    try eval(['nflags=length(marks_struct.',info_type,');']);
    catch, nflags=0;end
end

flagind=1;

switch info_type

    case 'chan_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'chan_info')
                flagind=find(strcmp(mark_prop{1},{marks_struct.chan_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{5};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{5},marks_struct.chan_info(flagind).flags],2);
                end
            end
        end
        if ~exist('tmpflags');
            tmpflags=zeros(length(mark_prop{5}),1);            
        end
        marks_struct.chan_info(flagind).label=mark_prop{1};
        marks_struct.chan_info(flagind).line_color=mark_prop{2};
        marks_struct.chan_info(flagind).tag_color=mark_prop{3};
        marks_struct.chan_info(flagind).order=mark_prop{4};
        marks_struct.chan_info(flagind).flags=tmpflags;
        
    case 'comp_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'comp_info')
                flagind=find(strcmp(mark_prop{1},{marks_struct.comp_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{5};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{5},marks_struct.comp_info(flagind).flags],2);
                end
            end
        end
        if ~exist('tmpflags');
            tmpflags=zeros(length(mark_prop{5}),1);            
        end
        marks_struct.comp_info(flagind).label=mark_prop{1};
        marks_struct.comp_info(flagind).line_color=mark_prop{2};
        marks_struct.comp_info(flagind).tag_color=mark_prop{3};
        marks_struct.comp_info(flagind).order=mark_prop{4};
        marks_struct.comp_info(flagind).flags=tmpflags;
        
    case 'time_info'
        if ~isempty(marks_struct);
            if isfield(marks_struct,'time_info')
                flagind=find(strcmp(mark_prop{1},{marks_struct.time_info.label}));
                if isempty(flagind);
                    flagind=nflags+1;
                    tmpflags=mark_prop{3};
                else
                    disp(['merging new flags into existing ''',mark_prop{1},''' mark label.']);
                    tmpflags=any([mark_prop{3};marks_struct.time_info(flagind).flags],1);
                end
            end
        end
        if ~exist('tmpflags');
            tmpflags=zeros(1,length(mark_prop{3}));            
        end
        marks_struct.time_info(flagind).label=mark_prop{1};
        marks_struct.time_info(flagind).color=mark_prop{2};
        marks_struct.time_info(flagind).flags=tmpflags;
        
        
    otherwise
        disp('check field string...');
        
end