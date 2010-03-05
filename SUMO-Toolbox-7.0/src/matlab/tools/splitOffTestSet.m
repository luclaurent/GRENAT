function [trainingSamples trainingValues testSamples testValues] = splitOffTestSet(samples, values, testPerc);

% splitOffTestSet (SUMO)
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
%	[trainingSamples trainingValues testSamples testValues] = splitOffTestSet(samples, values, testPerc);
%
% Description:
%	Make a random selection of test samples and training samples
%	out of a given set

data = shuffleRows([samples values]);

ntraining = round(size(data,1)*(1-testPerc));

trainingSamples = data(1:ntraining,1:size(samples,2));
trainingValues = data(1:ntraining,size(samples,2)+1:end);

testSamples = data(ntraining+1:end,1:size(samples,2));
testValues = data(ntraining+1:end,size(samples,2)+1:end);


