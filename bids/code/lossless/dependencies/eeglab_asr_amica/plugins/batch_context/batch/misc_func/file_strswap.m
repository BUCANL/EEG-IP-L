function swapstr=file_strswap(fname,varargin)

for i=1:length(varargin)
    if mod(i,2);
        if strcmp(varargin{i}(1),'[') && strcmp(varargin{i}(end),']');
            varargin{i}=varargin{i}(2:end-1);
        end
    end
end

strswap_struct=struct(varargin{:});
keystr=fieldnames(strswap_struct);
valstr=struct2cell(strswap_struct);

fid=fopen(fname,'r');
str=fread(fid,'char');
swapstr=char(str');

for i=1:length(keystr);
    swapstr=strrep(swapstr,['[',keystr{i},']'],valstr{i});
end
