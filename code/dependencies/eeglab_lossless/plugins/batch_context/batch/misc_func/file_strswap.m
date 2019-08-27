% file_strswap() - Execute a string swap on a given file based on passed varargs.
%                  Functions as a find and replace in a given file.
% Usage:
%  >> newstr = file_strswap(fname, varargin)
%
% Required Inputs:
%   fname   = File name to execute swaps on. This function opens the file
%			  internally.
%
% Optional Inputs:
%	Any given pair of strings to swap. See Batch Context documentation for
%	proper syntactical usage.
%
% Outputs:
%   swapstr = Updated output in which instances of key strings have
%             been swapped with their respective val strings.
%
% See also: pop_runhtb(), key_strswap()

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by James A. Desjardins, Allan Campopiano, and Andrew Lofts
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
