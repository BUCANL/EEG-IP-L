% ksdensity() - kernel density estimate, computes a probability density
%               estimate using the samples from the vector x
%
%               This function is being made to replicate the ksdensity function
%               in Octave but only to the extent that we need in the pipeline
%               further improvements can be made in the future. Therefore we 
%               only provide one interface.
% 
% Usage:
%   >>  [y, xi] = ksdensity(x, 'width', width)
%
% Inputs:
%   x     - input data to sample from
%   width - width of the normal distribution
%
% Outputs:
%   y  - vector of density values
%   xi - points covering range of data
%
% See also:
%   Matlab reference for ksdensity()
% 
% Reference to Bowman, A. W., and A. Azzalini. Applied
% Smoothing Techniques for Data Analysis. New York: Oxford
% University Press, 1997. 
% same as Matlab authors

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
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

function [fout0, xout, u, ksinfo] = ksdensity(yData, varargin)

% Verify they arnt using non supported calls
if nargout ~= 2 || nargin ~= 3
    error(['This version of ksdensity() may only be called with 2 in' ...
             'parameters and 2 out params']);
    help ksdensity;
end

if ~(isvector(yData) && strcmp(varargin{1}, 'width') && isscalar(varargin{2}))
    error(['This version of ksdensity() must be called with' ...
            '[y, xi] = ksdensity(<vector>, ''width'', <scalar width>']);
    help ksdensity;
end
width = varargin{2};

if size(yData, 2) == 1
    yData = yData';
end

stepsize = (max(yData)-min(yData))/100;
xi = min(yData):stepsize:max(yData)-stepsize;

fun = @(x) normpdf(x, 0, width);

fout0 = zeros(1, 100);

for i=1:100
    fout0(i) = sum(fun(xi(i) - yData))/100;
end

xout = xi;
