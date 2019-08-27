% pop_rfind() - Search for BIDS compliant files inside of query folders.
%
% Usage:
%   >>  pop_rfind(projRoot,searchRoot)
%
% Inputs:
%   projRoot       - Root name of the project.
%   searchRoot     - Path to begin searching from.
%    
% Outputs:
%   Formatted pop_runhtb compliant paths to each .set file inside of a
%   given searchRoot folder.
%
% See also:
%   pop_runhtb();
%

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Tyler K. Collins
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program (LICENSE.txt file in the root directory); if not, 
% write to the Free Software Foundation, Inc., 59 Temple Place,
% Suite 330, Boston, MA  02111-1307  USA

function out=pop_rfind(projRoot, searchRoot)
    out = '';

    split = bc_strsplit(projRoot,'/'); % Get project name.
    projName = split(end);

    
    filePattern = fullfile(searchRoot, 'sub-*'); % Search for BIDS pattern.
    allFiles = dir(filePattern);
    
    % Loops over all results
    for k = 1 : length(allFiles)
        subj = allFiles(k).name;
        % Search for the generic path, and then if it exists, grab the
        % file name. Afterwards, the absolute path is created.
        fileSearch = fullfile(sprintf('%s/%s/eeg/',searchRoot,subj),'*.set');
        singleFile = dir(fileSearch);
        fullPath = strrep(fileSearch,'*.set',singleFile.name);
        
        % Split the absolute path into a cell array, and find where the
        % project name is in the array. Only include path information from
        % that point on.
        reSplit = strsplit(fullPath,'/');
        ind = find(ismember(reSplit,projName));
        finalPath = '';
        for i = ind+1 : length(reSplit) % Matlab doesn't have a cell2str...
            finalPath = sprintf('%s%s/',finalPath, reSplit{i});
        end
                
        % Build return variable.
        out = sprintf('%s%s\n',out,finalPath(1:end-1));
    end
end

% THIS FUNCTION IS ONLY HERE TO USE THIS PARTICULAR TYPE OF STRSPLIT
% WITHOUT HAVING TO INRODUCE ANOTHER FILE WHICH MAY CONFUSE PEOPLE OR ALLOW
% AN UNSAFE DEPENDENCY.
function terms = bc_strsplit(s, delimiter)
%STRSPLIT Splits a string into multiple terms
%
%   terms = strsplit(s)
%       splits the string s into multiple terms that are separated by
%       white spaces (white spaces also include tab and newline).
%
%       The extracted terms are returned in form of a cell array of
%       strings.
%
%   terms = strsplit(s, delimiter)
%       splits the string s into multiple terms that are separated by
%       the specified delimiter. 
%   
%   Remarks
%   -------
%       - Note that the spaces surrounding the delimiter are considered
%         part of the delimiter, and thus removed from the extracted
%         terms.
%
%       - If there are two consecutive non-whitespace delimiters, it is
%         regarded that there is an empty-string term between them.         
%
%   Examples
%   --------
%       % extract the words delimited by white spaces
%       ts = strsplit('I am using MATLAB');
%       ts <- {'I', 'am', 'using', 'MATLAB'}
%
%       % split operands delimited by '+'
%       ts = strsplit('1+2+3+4', '+');
%       ts <- {'1', '2', '3', '4'}
%
%       % It still works if there are spaces surrounding the delimiter
%       ts = strsplit('1 + 2 + 3 + 4', '+');
%       ts <- {'1', '2', '3', '4'}
%
%       % Consecutive delimiters results in empty terms
%       ts = strsplit('C,Java, C++ ,, Python, MATLAB', ',');
%       ts <- {'C', 'Java', 'C++', '', 'Python', 'MATLAB'}
%
%       % When no delimiter is presented, the entire string is considered
%       % as a single term
%       ts = strsplit('YouAndMe');
%       ts <- {'YouAndMe'}
%

%   History
%   -------
%       - Created by Dahua Lin, on Oct 9, 2008
%

%% parse and verify input arguments

assert(ischar(s) && ndims(s) == 2 && size(s,1) <= 1, ...
    'strsplit:invalidarg', ...
    'The first input argument should be a char string.');

if nargin < 2
    by_space = true;
else
    d = delimiter;
    assert(ischar(d) && ndims(d) == 2 && size(d,1) == 1 && ~isempty(d), ...
        'strsplit:invalidarg', ...
        'The delimiter should be a non-empty char string.');
    
    d = strtrim(d);
    by_space = isempty(d);
end
    
%% main

s = strtrim(s);

if by_space
    w = isspace(s);            
    if any(w)
        % decide the positions of terms        
        dw = diff(w);
        sp = [1, find(dw == -1) + 1];     % start positions of terms
        ep = [find(dw == 1), length(s)];  % end positions of terms
        
        % extract the terms        
        nt = numel(sp);
        terms = cell(1, nt);
        for i = 1 : nt
            terms{i} = s(sp(i):ep(i));
        end                
    else
        terms = {s};
    end
    
else    
    p = strfind(s, d);
    if ~isempty(p)        
        % extract the terms        
        nt = numel(p) + 1;
        terms = cell(1, nt);
        sp = 1;
        dl = length(delimiter);
        for i = 1 : nt-1
            terms{i} = strtrim(s(sp:p(i)-1));
            sp = p(i) + dl;
        end         
        terms{nt} = strtrim(s(sp:end));
    else
        terms = {s};
    end        
end
end