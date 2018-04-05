% struct2text() - Write a workspace structure to a human readable formated text file.
%
%
% Usage:
%  >> struct2text(instruct,savename)
%
% Graphical Interface:
%
% Required Inputs:
%   instruct   = Name of the workspace structure to be writen to text file.
%
%   fname      = Name of the formated text file to be writen.
%
% Optional Inputs:
%
% Outputs:
%
% Notes:
%
% Typical use:
%
% See also: pop_batch_edit, pop_context_edit(),

%Copyright (C) 2013 BUCANL
%
%Code originally written by Allan Campopiano with contributions from 
%James Desjardins and Andrew Lofts, supported by NSERC funding to 
%Sidney J. Segalowitz at the Jack and Nora Walker Canadian Centre for 
%Lifespan Development Research (Brock University), and a Dedicated Programming 
%award from SHARCNet, Compute Ontario.
%
%This program is free software; you can redistribute it and/or modify
%it under the terms of the GNU General Public License as published by
%the Free Software Foundation; either version 2 of the License, or
%(at your option) any later version.
%
%This program is distributed in the hope that it will be useful,
%but WITHOUT ANY WARRANTY; without even the implied warranty of
%MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%GNU General Public License for more details.
%
%You should have received a copy of the GNU General Public License
%along with this program (LICENSE.txt file in the root directory); if not, 
%write to the Free Software Foundation, Inc., 59 Temple Place,
%Suite 330, Boston, MA  02111-1307  USA


function struct2text(instruct,savename)

fid = fopen(savename, 'wt+');
fn=fieldnames(instruct);

for i = 1:length(fn)
    
    if iscell(instruct.(fn{i}))
        fprintf(fid, '%s\n\t',fn{i});
        
        
        for j=1:length(instruct.(fn{i}))
            
            if j<length(instruct.(fn{i}))
                if isempty(instruct.(fn{i}){j})
                    fprintf(fid, '%s\n\t',' ');
                else
                    fprintf(fid, '%s\n\t',instruct.(fn{i}){j});
                end
            else
                if isempty(instruct.(fn{i}){j})
                    fprintf(fid, '%s\n',' ');
                else
                    fprintf(fid, '%s\n',instruct.(fn{i}){j});
                end
            end
        end

    elseif isnumeric(instruct.(fn{i}))
        fprintf(fid, '%s\n\t',fn{i});
        if isempty(instruct.(fn{i}))
            fprintf(fid, '%s\n',' ');
        else
            fprintf(fid, '%s\n',num2str(instruct.(fn{i})));
        end
    elseif ischar(instruct.(fn{i}))
        if ~isempty(instruct.(fn{i}))
            fprintf(fid, '%s\n\t',fn{i});
            fprintf(fid, '%s\n',instruct.(fn{i}));
        else
            fprintf(fid, '%s\n\t',fn{i});
            fprintf(fid, '%s\n',' ');
        end
    elseif isstruct(instruct.(fn{i}))
        fprintf(fid, '%s\n',fn{i});
        print_report(instruct.(fn{i}),fn{i},fid);
    elseif islogical(instruct.(fn{i}))
        fprintf(fid, '%s\t',fn{i});
        fprintf(fid, '%s\t',num2str(instruct.(fn{i})));
        nl=1;
    end
    if i==length(fn)
        fprintf(fid, '%s\n',' ');
    end
end

if nargin==1;
    fclose(fid);
end
