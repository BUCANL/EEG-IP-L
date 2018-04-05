function out=trimstd(data,percent)

if percent<1;
    disp('multiplying percent input by 100...');
    percent=percent*100;
end

npnts=length(data);
nppnts=round(npnts*(percent/100)/2);
srtdata=sort(data);

%Windsorize...
srtdata(1:nppnts)=srtdata(nppnts+1);
srtdata(npnts-(nppnts+1):end)=srtdata(npnts-(nppnts+1)-1);
out=std(srtdata);

%out=std(srtdata(nppnts+1:npnts-(nppnts+1)));

            
            
            
            
%switch dim
%    case 1
%        
%        for i=1:size(data,3);
%            
%            npnts=size(data,2);
%            nppnts=round(npnts*(percent/100));
%            srtdata=sort(data(:,:,i),2);
%            
%            out(:,:,i)=std(srtdata(nppnts+1:npnts-(nppnts+1),:),[],dim);
%        
%        end
%        
%    case 2
%
%        for i=1:size(data,3);
%            size(data(:,:,i))
%
%            npnts=size(data,1);
%            nppnts=round(npnts*(percent/100));
%            srtdata=sort(data(:,:,i),1);
%            size(srtdata)
%            nppnts+1
%            npnts-(nppnts+1)
%            out(:,:,i)=std(srtdata(:,nppnts+1:npnts-(nppnts+1)),[],dim);
%
%        end
%
%end
        
        