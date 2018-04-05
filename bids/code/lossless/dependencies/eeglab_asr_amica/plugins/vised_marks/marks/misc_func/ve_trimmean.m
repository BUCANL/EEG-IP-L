function trm_m = ve_trimmean(data,ptrim,dim)
% 
% if ptrim > 1;
%     ptrim = ptrim/100;
% end
% 
% ntotal = size(data);
% ntrim = round(ntotal*ptrim);
% 
% data_srt = sort(data);
% 
% trm_m = mean(data_srt(ntrim+1:ntotal-ntrim,:,:));

if nargin < 3;
    dim = 1; % by default, trim rows
end

if ptrim >= 1;
    ptrim = ptrim/100;
end

ptrim = ptrim/2;

if dim==1; % if we are trimming rows
    ntotal = size(data,2);
else % if we are trimming columns
    ntotal = size(data,1);
end

ntrim = round(ntotal*ptrim);
data_srt = sort(data);

%Take 1/2 of the requested amount off the top and off the bottom
if dim==1; % if we are trimming rows
    trm_m = mean(data_srt(1:size(data_srt,1),ntrim+1:ntotal-ntrim));   
else % if we are trimming columns
    trm_m = mean(data_srt(ntrim+1:ntotal-ntrim,1:size(data_srt,2)));
end