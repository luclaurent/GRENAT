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
%	Calculate the accuracy of the givin model using Leave-One-Out crossvalidation

% do not change the model
newModel = model;
samples = getSamplesInModelSpace(model);
values = getValues(model);

n = size(samples,1);
cv = zeros(n,length(outputIndex));

for i=1:n
	% Get training samples/values subset
	trainingSamples = [samples(1:i-1,:) ; samples(i+1:end,:)];
	trainingValues = [values(1:i-1,:) ; values(i+1:end,:)];

	% Build the model through p and t
	modelFold = constructInModelSpace(model, trainingSamples, trainingValues);
	
	% Evaluate the model on the test sample
	cv(i,:) = evaluateInModelSpace(modelFold,samples(i,:));	
end

% Calculate global score using error function
score = feval(getErrorFcn(m),values(:,outputIndex),cv);
