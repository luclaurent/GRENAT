function [deltai wi likelihood evidenceRatios] = getAICInfo(models);

% getAICInfo (SUMO)
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
%	[deltai wi likelihood evidenceRatios] = getAICInfo(models);
%
% Description:
%	Return metrics related to Akaike's Information Criteria:
%	The Akaike weights wi, the relative differences between the AIC scores,
%	the likelihood of each model and its evidence ratio.
%	Theory comes from the book: Model Selection and Multimodal Inference
%	by Kenneth P Burnham and David R Anderson

n = length(models);

[numInputs numOutputs] = models{1}.getDimensions();

aic = zeros(length(models),numOutputs);
for i=1:n
	%Get all the AIC values
	aic(i,:) = calculateAIC(models{i});
end
 
%Find AICmin
[smallestAic smallestIndex] = min(aic,[],1);

%Calculate the deltas
deltai = aic - repmat(smallestAic,n,1);

%Calculate the likelihoods
likelihood = exp(-0.5 .* deltai);

%Calculate the Akaike weights
likelihoodSum = sum(likelihood,1);
wi = likelihood ./ repmat(likelihoodSum,size(likelihood,1),1);

%Calculate the evidence ratios vs the best wi
bestwi = wi(smallestIndex,:);
evidenceRatios = wi ./ repmat(bestwi,size(likelihood,1),1);
