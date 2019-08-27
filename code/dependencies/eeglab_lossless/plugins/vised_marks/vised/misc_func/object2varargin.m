function outcell = object2varargin(inobj,exclude)

keys = fieldnames(inobj);

j=0;
for i=1:length(keys);
    if ~isempty(eval(['inobj.',keys{i}])) 
        if isempty(find(strcmp(keys{i},exclude)));
            j=j+1;
            outcell{j}=keys{i};
            j=j+1;
            outcell{j}=eval(['inobj.',keys{i}]);
        end
    end
end