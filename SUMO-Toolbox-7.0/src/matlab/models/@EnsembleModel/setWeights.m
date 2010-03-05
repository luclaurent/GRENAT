function s = setWeights( s,w )

% setWeights (SUMO)
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
%	s = setWeights( s,w )
%
% Description:
%	Set the weights for the ensemble members, should be a scalar or vector
%	The weights will be normalized so they sum to 1.

if(length(w) == 1)
	s.weights = ones(1,length(s.models)) * w;
elseif(length(w) ~= length(s.models))
	error(sprintf('The number of weights (%d) does not match the number of ensemble members (%d)',length(w),length(s.models)));
else
	s.weights = w;
end

% normalize so sum is 1	
s.weights = s.weights ./ sum(s.weights);

