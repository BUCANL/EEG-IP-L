function [outarray,outind]=marks_array2flags(inarray,varargin)

%% handle varargin
g=struct(varargin{:});

try g.flag_dim; catch, g.flag_dim='row'; end; %row = return column of row flags, col = return row of column flags

try g.init_method; catch, g.init_method='q'; end; %q = quantile outlier classification, z = zscore outlier classification, fixed = outlier cutoffs.
try g.init_vals; catch, g.init_vals=[]; end; %distribution values for flagging by flag_crit = 'q' or 'fixed'

try g.init_dir; catch, g.init_dir='both'; end; %pos, neg, both
try g.init_crit; catch, g.init_crit=[]; end; %outlier distance classification

try g.flag_method; catch, g.flag_method='z_score'; end; %fixed, dist
try g.flag_val; catch, g.flag_val=3; end; % value of percentage

try g.trim; catch, g.trim=0; end;
try g.plot_figs; catch, g.plot_figs='off';end;

%% if flagdir is column wise rotate the inarray.
if strcmp(g.flag_dim,'col');
    inarray=inarray';
end

%% return flags indices (outind) from input measure (inarray) 

%allocate output variables
outarray=zeros(size(inarray));
outind=1:size(inarray,2);

% for each column flag cell of inarray
for coli=outind;
    %Calculate mean and standard deviation for each column
    switch g.init_method
        case 'q'
            switch length(g.init_vals)
                case 1
                    qval(1)=.5-g.init_vals;
                    qval(2)=.5;
                    qval(3)=.5+g.init_vals;                    
                case 2
                    qval(1)=g.init_vals(1);
                    qval(2)=.5;
                    qval(3)=g.init_vals(2);                                        
                case 3
                    qval(1)=g.init_vals(1);
                    qval(2)=g.init_vals(2);
                    qval(3)=g.init_vals(3);
            end
            m_dist(coli)=quantile(inarray(:,coli),qval(2));
            %s_dist(coli)=ve_trimstd(inarray(:,coli),g.trim);
            l_dist(coli)=quantile(inarray(:,coli),qval(1));
            u_dist(coli)=quantile(inarray(:,coli),qval(3));
            l_out(coli)=m_dist(coli)-(m_dist(coli)-l_dist(coli))*g.init_crit;
            u_out(coli)=m_dist(coli)+(u_dist(coli)-m_dist(coli))*g.init_crit;
        case 'z'
            m_dist(coli)=ve_trimmean(inarray(:,coli),g.trim);
            s_dist(coli)=ve_trimstd(inarray(:,coli),g.trim);
            l_dist(coli)=m_dist(coli)-s_dist(coli);
            u_dist(coli)=m_dist(coli)+s_dist(coli);
            l_out(coli)=m_dist(coli)-s_dist(coli)*g.init_crit;
            u_out(coli)=m_dist(coli)+s_dist(coli)*g.init_crit;
        case 'fixed'
            %not implemented yet.
    end
    
    %for each row
    for rowi=1:size(inarray,1);
        %flag outlying values
        if strcmp(g.init_dir,'pos')||strcmp(g.init_dir,'both');
            %for positive outliers
            if inarray(rowi,coli)>u_out(coli);
                outarray(rowi,coli)=1;
            end
        end
        if strcmp(g.init_dir,'neg')||strcmp(g.init_dir,'both');
            %for negative outliers
            if inarray(rowi,coli)<l_out(coli);
                outarray(rowi,coli)=1;
            end
        end
    end
end

%average column of outarray
critrow=squeeze(mean(outarray,2));
%mean and sd of average outarray column
mccritrow=mean(critrow);
sccritrow=std(critrow);

%set the flag index threshold (may add quantile option here as well)
switch (g.flag_method);
    case 'fixed';
        rowthresh=g.flag_val;
    case 'z_score'
        rowthresh=mccritrow+sccritrow*g.flag_val;
end

%get indeces of rows beyond threshold
outind=find(critrow>rowthresh);

%% if flagdir is column wise rotate the outarray and ouind.
if strcmp(g.flag_dim,'col');
    inarray=inarray';
    outarray=outarray';
    outind=outind';
end




%% plots
if strcmp(g.plot_figs,'on')
    
    if strcmp(g.flag_dim,'row')        
        figure;
%        subplot(1,3,[1,2]);
        surf(double(inarray),'LineStyle','none');
        colorbar('WestOutside');
        axis('tight');
        view(0,90);
        
%        subplot(1,3,[3]);
        figure;
        scatter(1:length(m_dist),m_dist,20,...
            'MarkerEdgeColor',[.3 .3 .3],...
            'MarkerFaceColor',[.3 .3 .3]);
        hold on;
        for i=1:size(outarray,2);
            outvals=[];
            outvals=inarray(find(outarray(:,i)),i);
            scatter(ones(size(outvals))*i,outvals,20,'r+');
        end
        scatter(1:length(l_dist),l_dist,20,...
            'MarkerEdgeColor',[.65 .65 .65],...
            'MarkerFaceColor',[.65 .65 .65]);
        scatter(1:length(u_dist),u_dist,20,...
            'MarkerEdgeColor',[.65 .65 .65],...
            'MarkerFaceColor',[.65 .65 .65]);
        scatter(1:length(l_out),l_out,20,...
            'MarkerEdgeColor',[.3 .3 .7],...
            'MarkerFaceColor',[.3 .3 .7]);
        scatter(1:length(u_out),u_out,20,...
            'MarkerEdgeColor',[.3 .3 .7],...
            'MarkerFaceColor',[.3 .3 .7]);
        axis('tight');
        %view(90,90)

        figure;
        %subplot(1,3,[1,2]);
        surf(outarray,'LineStyle','none');
        colorbar('WestOutside');
        axis('tight');
        view(0,90);
        
        %subplot(1,3,[3]);
        figure;
        plot(critrow);
        hold on;plot(ones(size(critrow))*rowthresh,'r');
        axis('tight');
        view(90,270)
    else
        figure;
%        subplot(1,3,[1,2]);
        surf(double(inarray),'LineStyle','none');
        colorbar('WestOutside');
        axis('tight');
        view(0,90);
        
%        subplot(1,3,[3]);
        figure;
        scatter(1:length(m_dist),m_dist,20,...
            'MarkerEdgeColor',[.3 .3 .3],...
            'MarkerFaceColor',[.3 .3 .3]);
        hold on;
        for i=1:size(outarray,1);
            outvals=[];
            outvals=inarray(i,find(outarray(i,:)));
            scatter(ones(size(outvals))*i,outvals,20,'r+');
        end
        scatter(1:length(l_dist),l_dist,20,...
            'MarkerEdgeColor',[.65 .65 .65],...
            'MarkerFaceColor',[.65 .65 .65]);
        scatter(1:length(u_dist),u_dist,20,...
            'MarkerEdgeColor',[.65 .65 .65],...
            'MarkerFaceColor',[.65 .65 .65]);
        scatter(1:length(l_out),l_out,20,...
            'MarkerEdgeColor',[.3 .3 .7],...
            'MarkerFaceColor',[.3 .3 .7]);
        scatter(1:length(u_out),u_out,20,...
            'MarkerEdgeColor',[.3 .3 .7],...
            'MarkerFaceColor',[.3 .3 .7]);
        axis('tight');
        view(90,270)
        
        figure;
        %subplot(3,1,[1,2]);
        surf(outarray,'LineStyle','none');
        axis('tight');
        view(0,90);
        
        %subplot(3,1,[3]);
        figure;
        plot(critrow);
        hold on;plot(ones(size(critrow))*rowthresh,'r');
        axis('tight');
    end
end
