% ExportOpenFormat() - description of the function
%
% Usage:
%   >>  out = ExportOpenFormat( in1, in2, in3 );
% Inputs:
%   in1     - Continuous data vector.
%   in2     - Epoch length NPts.
%   in3     - Overlap offset.
%    
% Outputs:
%   out     - Segmented data vector.
%
% See also: 
%   POP_SEGMENTION, EEGLAB 

% Copyright (C) <2006>  <James Desjardins>
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
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function out = ExportERPscoreFormat(EEG,FileName,FilePath,OutputExtension,PreStimPts);
PreStimPts=num2str(PreStimPts);
if nargin < 3
	help ExportERPscoreFormat;
	return;
end;	

if ~isfield(EEG, 'NTrialsUsed');
    EEG.NTrialsUsed=1;
end

% Header Brock Format Average
Header = 'AvgERPfile v6,  ';
Header = sprintf('%s%d', Header, EEG.NTrialsUsed);
Temp = ' files_averaged,  ';
Header = sprintf('%s  %s', Header,Temp);
Header = sprintf('%s%d', Header, length(EEG.data(1,:,1)));
Temp = ' NptsPerEpoch,  ';
Header = sprintf('%s  %s', Header,Temp);
Header = sprintf('%s%d', Header, length(EEG.data(:,1,1)));
Temp = 'channels';
Header = sprintf('%s  %s', Header,Temp);
for i=1:EEG.nbchan;
    Header=sprintf('%s ,%s',Header,EEG.chanlocs(i).labels);
end
Temp = ',  0 =stim categ,  0 =resp,  No_regression info,  1 =GainFactor, ';
Header = sprintf('%s  %s', Header,Temp);
Header = sprintf('%s%d', Header, EEG.srate);
Temp = ' =SampsPerSec,  ';
Header = sprintf('%s  %s', Header,Temp);

Header = sprintf('%s%s', Header, PreStimPts);

Temp = ' =#prestimPts,   0 0 0 =AvgRT/avgSD/avgn,';
Header = sprintf('%s  %s', Header,Temp);
%

TwelvePointThree=double(' %12.3f');
for i=1:EEG.pnts;
   PrintVector(i,:)=TwelvePointThree;
end
PrintVector=reshape(PrintVector',1,length(TwelvePointThree)*EEG.pnts);
PrintVector=char(PrintVector);
%%%%%

%%%%% Write to disk 
% Brock Format ERP file
eval(['fidBFA=fopen(''' char(FilePath) char(FileName) '.' char(OutputExtension) ''',''w'');'])

fprintf(fidBFA, '%s\r\n', Header);
eval(['fprintf(fidBFA,''' PrintVector '\r\n'',EEG.data'');']);

%%%%% Close files
fclose(fidBFA);
