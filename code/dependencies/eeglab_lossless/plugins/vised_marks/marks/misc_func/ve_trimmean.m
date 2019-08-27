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

if dim > 2;
    disp ('ERROR: dim must be 1 or 2.');
    return
end

if nargin < 3;
    dim = 1;
end

if ptrim >= 1;
    ptrim = ptrim/100;
end

ptrim = ptrim/2;

if dim==1;
    ntotal = size(data,1);
else
    ntotal = size(data,2);
end

ntrim = round(ntotal*ptrim);

%Take 1/2 of the requested amount off the top and off the bottom
if dim==1;
    data_srt = sort(data,1);
    trm_m = mean(data_srt(ntrim+1:ntotal-ntrim,1:size(data_srt,2)),1);   
else
    data_srt = sort(data,2);
    trm_m = mean(data_srt(1:size(data_srt,1),ntrim+1:ntotal-ntrim),2);
end