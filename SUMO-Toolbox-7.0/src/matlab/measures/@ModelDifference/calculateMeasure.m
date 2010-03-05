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
%	Evaluate the model by comparing it to the best model so far in the
%	history. Does not modify the model.

newModel = model;
% the best model is the first one in the trace

% no other model to compare to yet, return perfect score
if isempty(context.bestModels)
	score = repmat(+Inf,1,length(outputIndex));
	return;
else
	lastModel = context.bestModels{1};
end

[samples, lastValues] = getGrid(lastModel);
[samples, values] = getGrid(model);

% compare with best model
score = feval(getErrorFcn(m),values(:,outputIndex) , lastValues(:,outputIndex));

