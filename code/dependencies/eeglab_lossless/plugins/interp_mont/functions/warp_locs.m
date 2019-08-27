% EEG = warp_locs() - Interpolate current data to coordinates from a specified 
%                     coordinate file.
%
% Usage:
%   >>  EEG = warp_locs(EEG,coord_fname, 'transform',[cor_transmat],'manual','off');
%
% Inputs:
%   EEG         - input EEG structure
%   coord_fname - name of sfp file containing new channel coordinates.
%   varargin    - key/val pairs. See Options in pop_interpmont.
%
% Outputs:
%   EEG       - EEG structure updated with new coordinates.
%               input to 'manual' option of coregister.m. See help coregister.
% See also:
%   pop_interpmont

function EEG = warp_locs(EEG,coord_fname,varargin)

%g=struct(varargin{:});

try
    options = varargin;
    for index = 1:length(options)
        if iscell(options{index}) && ~iscell(options{index}{1}), options{index} = { options{index} }; end;
    end;
    if ~isempty( varargin ), g=struct(options{:});
    else g= []; end;
catch
    disp('warp_locs() error: calling convention {''key'', value, ... } error'); return;
end;

try g.landmarks; catch, g.landmarks = {};end
try g.transform; catch, g.transform = [0 0 0 0 0 0 1 1 1];end
try g.manual; catch, g.manual = 'off';end
try g.mesh; catch, g.mesh = '';end


if isempty(EEG.chanlocs(1).X)
    disp(sprintf('%s\n','No coordinate information found in the current dataset... doing nothing'));
    return
end

[newlocs] = coregister(EEG.chanlocs, ...
    coord_fname, ...
    'chaninfo1',EEG.chaninfo, ...
    'warp', g.landmarks, ...
    'transform',g.transform, ...
    'manual', g.manual, ...
    'mesh',g.mesh);

ndatch=length(EEG.chanlocs);
nndatch=size(newlocs.pnt,1)-ndatch;

for i=1:ndatch;
    EEG.chanlocs(i).X=newlocs.pnt(i,1);
    EEG.chanlocs(i).Y=newlocs.pnt(i,2);
    EEG.chanlocs(i).Z=newlocs.pnt(i,3);
end

for i=1:nndatch;
    EEG.chaninfo.nodatchans(i).X=newlocs.pnt(ndatch+i,1);
    EEG.chaninfo.nodatchans(i).Y=newlocs.pnt(ndatch+i,2);
    EEG.chaninfo.nodatchans(i).Z=newlocs.pnt(ndatch+i,3);
end

EEG = pop_chanedit(EEG,'convert','cart2all');
