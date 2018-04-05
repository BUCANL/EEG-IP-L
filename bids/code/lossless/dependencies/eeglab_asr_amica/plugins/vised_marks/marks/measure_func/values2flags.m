function [critrow,critcol,rowind,colind]=values2flags(EEG,inmeasure,flagdir,flagzcrit,critdir,critmethod,critvalue,chan_win_sd,varargin)

g=struct(varargin{:});

try g.trim; catch, g.trim=0; end;
%try g.fisherz; catch, g.fisherz='off'; end;
try g.plot_figs; catch, g.plot_figs='off';end;

critrow=[];
critcol=[];
rowind=[];
colind=[];

if strcmp(g.plot_figs,'on')
    figure;
    subplot(3,3,[2,3,5,6]);surf(double(inmeasure),'LineStyle','none');
    axis('tight');
    view(0,90);
    
    subplot(3,3,[1,4]);plot(squeeze(mean(inmeasure,2)));
    axis('tight');
    view(270,90)
    
    subplot(3,3,[8,9]);plot(squeeze(mean(inmeasure,1)));
    axis('tight');
end

if ~isempty(chan_win_sd);
    m_chan_win_sd=mean(chan_win_sd,2);
    s_chan_win_sd=std(chan_win_sd,[],2);
    s_thresh=m_chan_win_sd-s_chan_win_sd*1;
    
    if strcmp(g.plot_figs,'on')
        figure;plot(s_thresh);
        figure;
        subplot(3,3,[2,3,5,6]);surf(double(chan_win_sd),'LineStyle','none');
        axis('tight');
        view(0,90);
        
        subplot(3,3,[1,4]);plot(squeeze(mean(chan_win_sd,2)));
        axis('tight');
        view(270,90)
        
        subplot(3,3,[8,9]);plot(squeeze(mean(chan_win_sd,1)));
        axis('tight');
    end
else
    s_thresh=[];
end

%if strcmp(g.fisherz,'on');
%    for i=1:size(inmeasure,1);
%        inmeasure(i,:)=.5.*log((1+inmeasure(i,:))./(1-inmeasure(i,:)));
%    end
%end

if flagdir==1||flagdir==3;
    
    critrow=zeros(size(inmeasure));
    colind=1:size(inmeasure,2);
    nCol=length(colind);
    if strcmp(g.plot_figs,'on')
        hrowc = waitbar(0,['Testing column 0 of ', num2str(nCol), '...']);
    end
    for coli=colind;
        if strcmp(g.plot_figs,'on')
            waitbar(coli/nCol,hrowc, ...
                ['Testing column ', num2str(coli), ' of ', num2str(nCol), '...']);
        end
        if g.trim==0;
            mrrow(coli)=mean(inmeasure(:,coli),1);
            srrow(coli)=std(inmeasure(:,coli),[],1);
        else

            mrrow(coli)=ve_trimmean(inmeasure(:,coli),g.trim);
            srrow(coli)=ve_trimstd(inmeasure(:,coli),g.trim);

        end
        for rowi=1:size(inmeasure,1);
            if strcmp(critdir,'pos');
                if inmeasure(rowi,coli)>mrrow(coli)+srrow(coli)*flagzcrit;
                    if ~isempty(s_thresh);
                        if chan_win_sd(rowi,coli)>s_thresh(rowi);
                            critrow(rowi,coli)=1;
                        end
                    else
                        critrow(rowi,coli)=1;
                    end
                end
            else
                if inmeasure(rowi,coli)<mrrow(coli)-srrow(coli)*flagzcrit;
                    if ~isempty(s_thresh);
                        if chan_win_sd(rowi,coli)>s_thresh(rowi);
                            critrow(rowi,coli)=1;
                        end
                    else
                        critrow(rowi,coli)=1;
                    end
                end
            end
        end
    end
    
    if strcmp(g.plot_figs,'on')
        close(hrowc);
    end
    
    rowcritrow=squeeze(mean(critrow,2));
    mccritrow=mean(rowcritrow);
    sccritrow=std(rowcritrow);

    switch (critmethod);
        case 'fixed';
            rowthresh=critvalue;
        case 'distrib'
            rowthresh=mccritrow+sccritrow*critvalue;
    end
    
    rowind=find(rowcritrow>rowthresh);
    
    colcritrow=squeeze(mean(critrow,1));
    mrcritrow=mean(colcritrow);
    srcritrow=std(colcritrow);
    
    if strcmp(g.plot_figs,'on')
        figure;
        subplot(3,3,[2,3,5,6]);surf(critrow,'LineStyle','none');
        axis('tight');
        view(0,90);
        
        subplot(3,3,[1,4]);plot(rowcritrow);
        hold on;plot(ones(size(rowcritrow))*rowthresh,'r');
        axis('tight');
        view(270,90)
        
        subplot(3,3,[8,9]);plot(colcritrow);
        axis('tight');
    end
end


if flagdir==2||flagdir==3;

    critcol=zeros(size(inmeasure));
    colind=1:size(inmeasure,2);
    rowind=1:size(inmeasure,1);
    nRow=length(rowind);
    
    if strcmp(g.plot_figs,'on')
        hcolc = waitbar(0,['Testing row 0 of ', nRow, '...']);
    end
    
    for rowi=rowind;
        if strcmp(g.plot_figs,'on')
            waitbar(0,hcolc, ...
                ['Testing row ', num2str(rowi), ' of ', num2str(nRow), '...']);
        end
        mrcol(rowi)=mean(inmeasure(rowi,:),2);
        srcol(rowi)=std(inmeasure(rowi,:),[],2);
        for coli=1:size(inmeasure,2);
            if strcmp(critdir,'pos');
                if inmeasure(rowi,coli)>mrcol(rowi)+srcol(rowi)*flagzcrit;
                    if ~isempty(s_thresh);
                        if chan_win_sd(rowi,coli)>s_thresh(rowi);
                            critcol(rowi,coli)=1;
                        end
                    else
                        critcol(rowi,coli)=1;
                    end
                end
            else
                if inmeasure(rowi,coli)<mrcol(rowi)-srcol(rowi)*flagzcrit;
                    if ~isempty(s_thresh);
                        if chan_win_sd(rowi,coli)>s_thresh(rowi);
                            critcol(rowi,coli)=1;
                        end
                    else
                        critcol(rowi,coli)=1;
                    end
                end
            end
        end
    end

    if strcmp(g.plot_figs,'on')
        close(hcolc);
    end

    rowcritcol=squeeze(mean(critcol,2));
    mrcritcol=mean(rowcritcol);
    srcritcol=std(rowcritcol);
    
    colcritcol=squeeze(mean(critcol,1));
    mccritcol=mean(colcritcol);
    sccritcol=std(colcritcol);
    
    switch (critmethod);
        case 'fixed';
            colthresh=critvalue;
        case 'distrib'
            colthresh=mccritcol+sccritcol*critvalue;
    end
    
    colind=find(colcritcol>colthresh);
    
    if strcmp(g.plot_figs,'on')
        figure;
        subplot(3,3,[2,3,5,6]);surf(critcol,'LineStyle','none');
        axis('tight');
        view(0,90);
        
        subplot(3,3,[1,4]);plot(rowcritcol);
        axis('tight');
        view(270,90)
        
        subplot(3,3,[8,9]);plot(colcritcol);
        hold on;plot(ones(size(colcritcol))*colthresh,'r');
        axis('tight');
    end
end

