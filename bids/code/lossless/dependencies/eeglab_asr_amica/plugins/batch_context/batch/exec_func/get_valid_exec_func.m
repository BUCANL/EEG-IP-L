function cellstrexec = get_valid_exec_func()
    cellstrexec = {'ef_current_base'};
    [thisdir, ~, ~] = fileparts(which(mfilename()));
    dirlist = dir(thisdir);
    
    listf = regexp({dirlist.name}, '@(?<names>.*)_driver', 'names');
    for i = 1:numel(listf)
        % Don't include ef_base_driver
        if ~isempty(listf{i}) && ~strcmp(listf{i}.names, 'ef_base')
            cellstrexec = [cellstrexec ; listf{i}.names];
        end
    end
    cellstrexec = cellstrexec';
end

