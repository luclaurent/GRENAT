function [initialSamples, evaluatedSamples] = generate(s)

% generate (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[initialSamples, evaluatedSamples] = generate(s)
%
% Description:
%	Generates new samples using a Voronoi design.

% dimensions
[inDim, outDim] = s.getDimensions();

% generate the samples
if strcmp(s.designType, 'hammersley')
	initialSamples = i4_to_hammersley_sequence(inDim, s.points)';
else
	initialSamples = qrand(s.design, s.points);
end

% no evaluated samples
evaluatedSamples = [];
	
end
