% This function serves as a helper function that offloads the
% generation of the file names for given tasks submitted by batch context.

function [ mfile_name ] = mfile_name_gen(mfile_name, datafname, histfname, job_name)

if isempty(job_name) && isempty(mfile_name)
    mfile_name = [histfname '_' datafname];
end

% batch_dfn
mfile_name = key_strswap(mfile_name, 'batch_dfn', datafname);
% batch_hfn
mfile_name = key_strswap(mfile_name, 'batch_hfn', histfname);

if isempty(mfile_name)
    % Awe yeah recursion
    mfile_name = mfile_name_gen(job_name, datafname, histfname, job_name);
end


end

