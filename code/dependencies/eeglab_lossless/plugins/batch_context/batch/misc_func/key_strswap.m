% key_strswap() - Replace any instance of a key string surrounded by brackets
% (e.g. [keystr]) in a given string array with its key value swap string. 
%
% Usage:
%  >> instr=key_strswap(instr,keystr,swapstr)
%
% Required Inputs:
%   instr      = A string array that contains instances of a key string
%                that are to be replaced with key value swap strings.
%
%   keystr     = A string that can be found in the instr surrounded by
%                brackets (e.g. [fname]) and that is to be replaced with 
%                the characters in swapstr.
%
%   swapstr    = A string that will replace any instance of the keystr 
%                (surronded by brackets) in the instr.
%
% Outputs:
%   instr       = Updated instr with instances of keystr replaced swapst
%
% Notes: key_strswap is capable of replacing portions of the keystr
% instances in instr by adding comma separated options within the bracketed
% key strings in the instrin text. In its simplest form key_strswap replaces
% all instances of keystr in instr with swapstr. For example, given:
%
%   instr   ='The name of the input file is [infname]'
%   keystr  ='infname'
%   swapstr ='ABC_s01_task1_raw.set'
%
% ... instr=key_strswap(instr,keystr,swapstr); would result in:
% instr = 'The name of the input file is ABC_s01_task1_raw.set'
%
% By specifying specific swapstr characters within instr it is also
% possible to manipulate how the swapstr ends up being expressed in the
% resulting instr. This can be valuable when generating an
% ourput filename given an input file name in swapstr. For example, if we
% want to truncate the beginning of the infname and change the suffix of
% the infname when generating the output file name we could modify instr
% such that:
%
%   instr   ='The name of the output file is [_,1,infname,_,-1]_out.set'
%
% ... instr=key_strswap(instr,keystr,swapstr); would result in:
% instr = 'The name of the output file is s01_task1_out.set'
%
% The optional character and index options in the instr bracketed key
% string text determine what portions of the swapstr gets placed into the
% instr. Starting with "[_,1...", this cuts off the beginning of
% infname (because these optional characters preceed infname within the brackets) at
% (and including) the first "_" character from the left ("1" means first
% from the left). Then "...infname,_,-1]" cuts off the training part of
% infname (because these optional characters follow infname within the
% brackets) starting (and including) the final "_" character ("-1"
% indicates first from the right) in swapstr. Because key_strswap only
% replaces the keystr instances up-to and including the bracket, The
% "..]_out.set" ends up being appended to the end of the keystr in the
% resulting instr.
%
% See also: ef_gem_m(), batch_strswap()

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

function instr=key_strswap(instr,keystr,swapstr)

n_skip=1;

while length(strfind(instr,keystr))>=n_skip;
    
    i1=strfind(instr,keystr);
    i=i1(n_skip);
    
    %look for preceding "prepack" '[' without adjoining ']'...
    i1m1=[];
    prepack={};
    while isempty(i1m1);
        i=i-1;
        if i<1;break;end
        if strcmp(instr(i),'[');
            i1m1=i;
            if isempty(strfind(instr(i1m1:i1(n_skip)),']'));
                if i1(n_skip)-i>1;
                    c_ind=strfind(instr(i1m1+1:i1(n_skip)-1),',');
                    if length(c_ind==2)
                        prepack{1}=strtrim(instr(i1m1+1:i1m1+c_ind(1)-1));
                        prepack{2}=str2num(strtrim(instr(i1m1+c_ind(1)+1:i1m1+c_ind(2)-1)));
                    end
                end
            end
        end
    end
    %look for following "postpack" ']' without adjoining '['...
    i2=i1(n_skip)+length(keystr)-1;
    i=i2;
    i2p1=[];
    postpack={};
    while isempty(i2p1);
        i=i+1;
        if i>length(instr);break;end
        if strcmp(instr(i),']');
            i2p1=i;
            if isempty(strfind(instr(i2+1:i2p1-1),'['));
                if i-i2>1;
                    c_ind=strfind(instr(i2+1:i2p1-1),',');
                    if length(c_ind==2)
                        postpack{1}=strtrim(instr(i2+c_ind(1)+1:i2+c_ind(2)-1));
                        postpack{2}=str2num(strtrim(instr(i2+c_ind(2)+1:i2p1-1)));
                    end
                end
            end
        end
    end
    %perform the swap...
    if isempty(prepack)&&isempty(postpack);
        if strcmp(instr(i1(n_skip)-1),'[')&&strcmp(instr(i2+1),']')
            keyPack=instr(i1(n_skip)-1:i2+1);
            instr=strrep(instr,keyPack,swapstr);
        else
            n_skip=n_skip+1;
        end
    else
        keyPack=instr(i1m1:i2p1);

        if isempty(prepack)
            startInd=1;
        else
            preInds=[];
            preInds=strfind(swapstr,prepack{1});
            n_preInds=length(preInds);
            if prepack{2}>0;
                preInds_ind=prepack{2};
            else
                preInds_ind=n_preInds+1+prepack{2};
            end
            if isempty(preInds)
                startInd=1;
            else
                startInd=preInds(preInds_ind)+1;
            end             
        end

        if isempty(postpack)
            endInd=length(swapstr);
        else
            postInds=[];
            postInds=strfind(swapstr,postpack{1});
            n_postInds=length(postInds);
            if postpack{2}>0;
                postInds_ind=postpack{2};
            else
                postInds_ind=n_postInds+1+postpack{2};
            end
            endInd=postInds(postInds_ind)-1;
        end
        swapstr_root=swapstr(startInd:endInd);
        instr=strrep(instr,keyPack,swapstr_root);
    end
end

