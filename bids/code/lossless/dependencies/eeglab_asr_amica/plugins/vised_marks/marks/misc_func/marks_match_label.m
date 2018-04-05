function new_labels=marks_match_label(sub_labels,all_labels)

if ischar(sub_labels);
    sub_labels={sub_labels};
end

new_labels={};
j=0;
for i=1:length(sub_labels);
    for ii=1:length(all_labels);
        if ~isempty(strfind(all_labels{ii},sub_labels{i}));
            if isempty(find(strcmp(all_labels{ii},new_labels)));
                j=j+1;
                new_labels{j}=all_labels{ii};
            end
        end
    end
end
