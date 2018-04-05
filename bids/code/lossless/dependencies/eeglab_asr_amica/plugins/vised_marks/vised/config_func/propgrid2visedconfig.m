function vised_config = propgrid2visedconfig(propgrid,visedconfig)


if nargin<2;
    try parameters = evalin('base', 'vised_config');
        visedconfig=parameters;
    catch %if nonexistent in workspace
        visedconfig=init_vised_config;
    end
end

npg=length(propgrid.Properties);
for pi=1:npg;
    eval(['visedconfig.',propgrid.Properties(pi).Name,'=propgrid.Properties(pi).Value;']);
end

if ~isempty(visedconfig.color);
    if iscell(visedconfig.color);
        for i=1:length(visedconfig.color);
            if ~isempty(str2num(visedconfig.color{i}));
                visedconfig.color{i}=str2num(visedconfig.color{i});
            end
        end
    end
end

if length(visedconfig.color)==1;
    if isempty(visedconfig.color{1});
        visedconfig.color='';
    end
end

vised_config=[];

fields=fieldnames(visedconfig);
nf=length(fields);
for i=1:nf;
    eval(['vised_config.',fields{i},'=visedconfig.',fields{i},';']);
end