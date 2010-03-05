function [m, newModel, score] = calculateMeasure(m, model, context, outputIndex)

% calculateMeasure (SUMO)
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
%	[m, newModel, score] = calculateMeasure(m, model, context, outputIndex)
%
% Description:
%	Will simply reject models that don't conform to the minimum/maximum.

newModel = model;

% by default, we give the perfect score
score = zeros(1,length(outputIndex));

% no maximum and minimum defined - skip
if all(m.minima == -Inf) && all(m.maxima == +Inf)
	return;
end

% evaluate the model on a grid
[samples, values] = getGrid(model);

% convert complex outputs to modulus
values(:,m.complex) = abs(values(:,m.complex));


% look for values that are lower than the minima
if any(values < repmat(m.minima, size(values,1), 1))
	score = repmat(+Inf,1,length(outputIndex));
end

% look for values that are higher than the maxima
if any(values > repmat(m.maxima, size(values,1), 1))
	score = repmat(+Inf,1,length(outputIndex));
end
