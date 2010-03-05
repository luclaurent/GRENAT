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
%	Calculate the accuracy of the givin model using k-fold crossvalidation

% do not change the model
newModel = model;
samples = getSamplesInModelSpace(model);
values = getValues(model);

if (size(samples,1) > m.randomThreshold)
	m.partitionMethod = 'random';
	m.resetFolds = true;
end

% calculate number of folds
n = m.numFolds;

% calculate minimum number of samples in a fold (a fold can exceed this number by 1)
minfoldsize = floor(size(samples,1)/n);

% now generate the real size of every fold
remaining = size(samples,1) - minfoldsize * n;
alreadyAssigned = [];
for i = 1 : n
	% we add one additional sample to make sure every single one is
	% assigned to a fold
	m.folds{i}.size = minfoldsize + (remaining > 0);
	remaining = remaining - 1;
	
	% we calculate how many samples are missing from this fold
	alreadyAssigned = [alreadyAssigned m.folds{i}.testSet];
end

% do we reset each fold after each measure calculation?
if m.resetFolds
	% delete all fold data, begin anew
	for i = 1 : n
		m.folds{i}.testSet = [];
	end
	alreadyAssigned = [];
end


% as long as some samples have not been assigned to any test set, continue
i = 1;
while length(alreadyAssigned) < size(samples,1)

	% find a fold for which the specified fold size does not match the real
	% size by cycling through all folds, so that each fold is treated
	% equally
	while m.folds{i}.size == length(m.folds{i}.testSet)
		i = mod(i, n) + 1;
	end

	% we found a fold which needs another sample
	% we select one additional sample from ONLY the set of new
	% samples, we ignore the old samples (even those not in THIS test set)
	[m.folds{i}.testSet, added] = selectTestSet(samples, m.folds{i}.testSet, 1, m.partitionMethod, alreadyAssigned);

	% remove the missing sample, move on to the next fold
	alreadyAssigned = [alreadyAssigned added];
	i = mod(i, n) + 1;
end

% first prepare the folds, this saves us some time later
trainSamples = cell(n,1);
trainValues = cell(n,1);

for i=1:n
  tmp = samples;
  tmp(m.folds{i}.testSet,:) = [];
  trainSamples{i} = tmp;
 
  tmp = values;
  tmp(m.folds{i}.testSet,:) = [];
  trainValues{i} = tmp;
end

qqdata = cell(n,1);
models = cell(n,1);
errs = zeros(n,length(outputIndex));
errorFun = getErrorFcn(m);

% TODO: duplicate code !
if(getParallelMode(m))
  % this loop in parallel if possible
  parfor i=1:n
      %Build the model through the fold
      modelFold = constructInModelSpace(model, trainSamples{i}, trainValues{i});
      models{i} = modelFold;
      
      %Evaluate the model
      res = evaluateInModelSpace(modelFold,samples(m.folds{i}.testSet,:));
      
      %Calculate the error per fold
      a = values(m.folds{i}.testSet,outputIndex);
      b = res(:,outputIndex);
      errs(i,:) = feval(errorFun,a,b);
      
      qqdata{i} = [a b];
  end
else
  % do it in serial
  for i=1:n
      %Build the model through the fold
      modelFold = constructInModelSpace(model, trainSamples{i}, trainValues{i});
      models{i} = modelFold;
      
      %Evaluate the model
      res = evaluateInModelSpace(modelFold,samples(m.folds{i}.testSet,:));
      
      %Calculate the error per fold
      a = values(m.folds{i}.testSet,outputIndex);
      b = res(:,outputIndex);
      ee = feval(errorFun,a,b);
      
      errs(i,:) = ee;
      
      qqdata{i} = [a b];
  end
end

m.qqdata = cell2mat(qqdata);

%Total error is the average of the errors per fold
score = mean(errs,1);
