function s = init( s, samples, values )

% init (SUMO)
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
%	s = init( s, samples, values )
%
% Description:
%	This base class method simply sets all the necessary fields (dimension, samples, values, id, ...)

assert( size(samples,1) == size(values,1), 'Number of samples differs from number of values provided!' );

% initialize samples arrays
s.samples = samples;
s.values = values;
s.dimension = size(samples,2);
s.outputDimension = size(values,2);

% set transformation values to identity if not already set
% this happens if people are calling the modelSpace methods directly (ie.,
% they dont want scaling)
if(isempty(s.transformationValues))
    s.transformationValues = [zeros(1,s.dimension) ; ones(1,s.dimension)];
end

% generate semi-unique model id
persistent idCounter;

if isempty(idCounter)
	idCounter = 1;
end

s.modelId = idCounter;

idCounter = mod(idCounter, 2147483646+1) + 1;
