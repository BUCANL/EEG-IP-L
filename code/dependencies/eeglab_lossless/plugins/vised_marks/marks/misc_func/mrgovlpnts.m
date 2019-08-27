function outPnts=mrgOvlPnts(inPnts)

j=0;
for i=1:size(inPnts,1);
    if inPnts(i,2)>0;
        j=j+1;
        trmPnts(j,:)=inPnts(i,:);
    end
end

j=1;
outPnts(1,:)=trmPnts(1,:);
for i=1:size(trmPnts,1);
    if trmPnts(i,1)<outPnts(j,2);
        outPnts(j,2)=trmPnts(i,2);
    else
        j=j+1;
        outPnts(j,:)=trmPnts(i,:);
    end
end

        