function out_array=marks_label2index(marks_struct,labels,out_type,varargin)

%% INITIATE VARARGIN STRUCTURES...
try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('marks_label2index() error: calling convention {''key'', value, ... } error'); return;
end;

try g.exact; catch, g.exact='on';end
try g.invert; catch, g.invert='off';end

if strcmp(g.exact,'off')
    labels=marks_match_label(labels,{marks_struct.label});
end

if ischar(labels);
    labels={labels};
end

if ~exist('out_type')
    out_type='indexes';
end

fi=1;
for i=1:length(labels);
%    if length(marks_struct)>1
        try
            flagind(fi)=find(strcmp(labels{i},{marks_struct.label}));
            fi=fi+1;
        catch
            disp(['Asked for label ''',labels{i}, ''' that does not exist in ''marks'' structure... ignoring this label.']);
        end
%    else
%        flagind=1;
%    end
end

% Needed to find the length of an existing mark to make the new mark below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arbitrarily picks the last mark in the array that exists. Usually manual
% is the empty case

for r=1:length(flagind);
    if ~isempty(marks_struct(flagind(r)).flags)
        notempty_ind(r)=r;
    else
        notempty_ind(r)=0;
    end
end

flagscat = [];
for i=1:length(flagind);
        if length(size(marks_struct(flagind(i)).flags))==2;
            if isempty(marks_struct(flagind(i)).flags)
                % New Mark - Size based off of an existing array
                marks_struct(flagind(i)).flags=zeros(size(marks_struct(flagind(max(notempty_ind))).flags));
            end
            flagscat(i,:)=marks_struct(flagind(i)).flags;
        elseif length(size(marks_struct(flagind(i)).flags))==3;
            if isempty(marks_struct(flagind(i)).flags)
                % New Mark - Size based off of an existing array
                marks_struct(flagind(i)).flags=zeros(size(marks_struct(flagind(max(notempty_ind))).flags));
            end
            flagscat(i,:,:)=squeeze(any(marks_struct(flagind(i)).flags,2));
        end
end

% OLD
%%%%%%%%%%%%%%%%%%%%%%%
% % for i=1:length(labels);
% % 
% %      
% %     for ii=1:length(flagind);     
% %         if length(size(marks_struct(flagind(ii)).flags))==2;
% %             if isempty(marks_struct(flagind(ii)).flags)
% %                 marks_struct(flagind(ii)).flags=zeros(size(marks_struct(flagind(max(notempty_ind))).flags));
% %             end
% %             flagscat(i,:)=marks_struct(flagind(ii)).flags;
% %         elseif length(size(marks_struct(flagind(ii)).flags))==3;
% %             if isempty(marks_struct(flagind(ii)).flags)
% %                 marks_struct(flagind(ii)).flags=zeros(size(marks_struct(flagind(max(notempty_ind))).flags));
% %             end
% %             flagscat(i,:,:)=squeeze(any(marks_struct(flagind(ii)).flags,2));
% %         end
% %     end
% % end



flags=any(flagscat,1);
if strcmp(g.invert,'on')
    flags=~flags;
end

switch out_type
    case 'flags'
        out_array=flags;
    case {'indexes','indices'}
        out_array=find(flags);
    case 'bounds'
        bounds=find(diff(flags));
        if flags(1)==1;bounds=[0,bounds];end
        if flags(length(flags))==1;bounds=[bounds,length(flags)];end
        out_array=reshape(bounds,2,length(bounds)/2)';
        out_array(:,1)=out_array(:,1)+1;
end