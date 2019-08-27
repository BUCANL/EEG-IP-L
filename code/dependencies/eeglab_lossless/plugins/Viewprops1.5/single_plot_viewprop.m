function single_plot_viewprop(EEG, typecomp, chanorcomp,spec_opt, erp_opt, scroll_event, classifier_name, figinfo, ri)

% figure figinfo.rows and figinfo.columns
% -----------------------  
if ~typecomp && EEG.nbchan > 64
    disp('More than 64 electrodes: electrode locations not shown');
    plotelec = 0;
else
    plotelec = 1;
end;
count = ri;
if exist('fig','var')
    button = findobj('parent', fig, 'tag', ['comp' num2str(ri)]);
    if isempty(button) 
        error( 'pop_viewprops(): figure does not contain the component button');
    end;	
else
    button = [];
end;		

if isempty( button )
    % compute coordinates
    % -------------------
    X = mod(count-1, figinfo.column)/figinfo.column * figinfo.incx-10;  
    Y = (figinfo.rows-floor((count-1)/figinfo.column))/figinfo.rows * figinfo.incy - figinfo.sizewy*1.3;  

    % plot the head
    % -------------
    if ~strcmp(get(gcf, 'tag'), figinfo.figtag);
        figure(findobj('tag', figinfo.figtag));
    end;
    ha = axes('Units','Normalized', 'Position',[X Y figinfo.sizewx figinfo.sizewy].*figinfo.s+figinfo.q);
    if typecomp
        topoplot( ri, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
                 'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12);
    else
        if plotelec
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                      'off', 'style' , 'fill', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
        else
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                      'off', 'style' , 'fill','electrodes','off', 'chaninfo', EEG.chaninfo, 'numcontour', 8);
        end;
        % labels
        if ~typecomp && isfield(EEG.etc, 'ic_classification')
            classifiers = fieldnames(EEG.etc.ic_classification);
            if ~isempty(classifiers)
                if ~exist('classifier_name', 'var') || isempty(classifier_name)
                    if any(strcmpi(classifiers, 'ICLabel'));
                        classifier_name = 'ICLabel';
                    else
                        classifier_name = classifiers{1};
                    end
                else
                    classifier_name = classifiers{strcmpi(classifiers, classifier_name)};
                end
                if ri == chanorcomp(1) && size(EEG.icawinv, 2) ...
                        ~= size(EEG.etc.ic_classification.(classifier_name).classifications, 1)
                    warning(['The number of ICs do not match the number of IC classifications. This will result in incorrectly plotted labels. Please rerun ' classifier_name])
                end
                [prob, classind] = max(EEG.etc.ic_classification.(classifier_name).classifications(ri, :));
                t = title(sprintf('%s: %.0f%%', ...
                    EEG.etc.ic_classification.(classifier_name).classes{classind}, ...
                    prob*100));
                set(t, 'Position', get(t, 'Position') .* [1 -1.05 1])
            end
        end
    end
    axis square;

    % plot the button
    % ---------------
     if ~strcmp(get(gcf, 'tag'), figinfo.figtag);
         figure(findobj('tag', figinfo.figtag));
     end
    button = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
                       [X Y+figinfo.sizewy figinfo.sizewx figinfo.sizewy*0.18].*figinfo.s+figinfo.q, 'tag', ['comp' num2str(ri)]);
    set( button, 'callback', {@pop_prop_extended, EEG, typecomp, ri, NaN, spec_opt, erp_opt, scroll_event, classifier_name} );
end;
if typecomp
    set( button, 'backgroundcolor', COLACC, 'string', EEG.chanlocs(ri).labels); 	
else
    weightR = fastif(2.0*(1-prob)>= 1.0, 1.0,2.0*(1-prob));
    weightG = 1.0*(prob);
    set( button, 'backgroundcolor', [weightR weightG 0], 'string', int2str(ri)); 	
end
drawnow;
% count = count +1;inaccurate as its been abstracted
end