function handles = build_viewprop_handles(EEG, countHandles, chanorcomp, typecomp)
    BACKCOLOR = [0.8 0.8 0.8];    
    handles = cell(countHandles,1);
    for i=1 : countHandles;
        currentfigtag = ['selcomp' num2str(rand)]; % generate a random figure tag
        handles{i} = struct();
        handles{i}.figtag = currentfigtag;
        
        % set up the figure
        % -----------------
        handles{i}.column = ceil(sqrt( length(chanorcomp) ))+1;
        handles{i}.rows = ceil(length(chanorcomp)/handles{i}.column);
        if ~exist('fig','var')
            figure('name', handles{i}.figtag, 'tag', handles{i}.figtag,'numbertitle', 'off', 'color', BACKCOLOR);
            set(gcf,'MenuBar', 'none');
            pos = get(gcf,'Position');
            set(gcf,'Position', [pos(1) 20 800/7*handles{i}.column 600/5*handles{i}.rows]);
            handles{i}.incx = 120;
            handles{i}.incy = 110;
            handles{i}.sizewx = 100/handles{i}.column;
            if handles{i}.rows > 2
                handles{i}.sizewy = 90/handles{i}.rows;
            else 
                handles{i}.sizewy = 80/handles{i}.rows;
            end;
            pos = get(gca,'position'); % plot relative to current axes
            handles{i}.q = [pos(1) pos(2) 0 0];
            handles{i}.s = [pos(3) pos(4) pos(3) pos(4)]./100;
            axis off;
        end;
    end
end