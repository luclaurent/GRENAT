function [dim] = networkDimFromSamples( ns, numIn, numOut, p )

% networkDimFromSamples (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 6376 $
%
% Signature:
%	[dim] = networkDimFromSamples( ns, numIn, numOut, p )
%
% Description:
%	Given a number of datapoints, calculate a reasonable starting point for the network complexity
%	Note that this is just a simple heuristic and thus it should be treated as such

% ratio of network weights / number of samples
if(~exist('p','var'))
    p = 0.3;
end

% maximal number of nodes for a one layer network
maxH1 = 8;

% how many weights should we allow
nw = p * ns;

% Given a network structure: I - h1 - O
% Will a one layer network suffice?
% The number of weights is (assuming fully connected):
%       nw = Ih1 + Oh1 + h1 + O
% so:
%	h1 = (nw - O) / (I + O + 1)
h1 = ceil((nw - numOut) / (numIn + numOut + 1));

if(h1 <= maxH1)
	% One hidden layer is enough
	dim = [h1];
else
	% Given a network structure: I - h1 - h2 - O
	% The number of weights is (assuming fully connected):
	%	nw = (I*h1) + (h1*h2) + (h2*O) + (h1 + h2 + O)
	% We also assume that h1 == h2
	% This allows us to calculate h1 and h2
	% 	0 = h1^2 + (I+O+2)h1 + (O - nw)
	
	rts = roots([1 (numIn+numOut+2) (numOut-nw)]);
	rts = rts(rts > 0);
	h1 = ceil(rts(1));
	h2 = h1;

	dim = [h1 h2];
end
	
dim(dim < 1) = 1;
