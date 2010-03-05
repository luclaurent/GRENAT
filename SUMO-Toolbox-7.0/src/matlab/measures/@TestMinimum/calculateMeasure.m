function [this, newModel, score] = calculateMeasure(this, model, context, outputIndex)

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
%	[this, newModel, score] = calculateMeasure(this, model, context, outputIndex)
%
% Description:
%	Compares the given true optimum to the current one

% get sample values
samples = getSamplesInModelSpace(model);
values = getValues(model);
values = values(:, outputIndex);

fval = findMinimum( samples, values );
newModel = model;

% if no sample satisfy all constraints then assume Infinity
if isempty( fval )
	score = repmat(+Inf,1,length(outputIndex));
else
	score = feval(getErrorFcn(this), this.trueValue, fval );
end
