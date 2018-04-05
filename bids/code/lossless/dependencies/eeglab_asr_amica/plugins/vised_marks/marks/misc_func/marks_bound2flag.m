function flags=marks_bound2flag(bounds,flags)

for i=1:size(bounds,1);
    flags(bounds(i,1):bounds(i,2))=1;
end