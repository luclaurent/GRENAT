function [minimum, index] = findMinimum( samples, values )

% findMinimum (SUMO)
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
%	[minimum, index] = findMinimum( samples, values )
%
% Description:
%	Returns the minimum of values
%	   if unconstrained: min(values)
%	   else applyConstraints then min(filteredValues)

if isempty(samples)
	minimum = [];
	index = [];
else
	constraints = Singleton('ConstraintManager');
	index = constraints.satisfySamples(samples);
	[minimum, indexMin] = min( values(index,:), [], 1 );
	index = index(indexMin);
	
	if isempty( minimum )
		minimum = +Inf * ones(1,size(values,2));
		index = -1 * ones(size(values,2),1);
	end	
end
