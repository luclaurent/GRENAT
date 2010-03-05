function s = addNewSamples(s, samples, values)

% addNewSamples (SUMO)
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
%	s = addNewSamples(s, samples, values)
%
% Description:
%	Process newly evaluated samples: consider them as candidate neighbours
%	for older samples, and generate neighbourhoods for the new ones. Update
%	the gradient estimations and the voronoi tesselation.

s.logger.fine('Setting initial neighbourhoods of new samples...');

% no new samples, skip this process
if s.sampleSize == size(values,1)
	return;
end


% consider all samples not yet integrated in the system
tic;
totalTime = 0;
for i = s.sampleSize+1 : size(values,1)
    
    %{
    if mod(i, 50) == 0
        lastTime = toc;
        totalTime = totalTime + lastTime;
        disp(sprintf('Processing sample %d, %5.1f for last 50 samples, %5.1f time passed', i, lastTime, totalTime));
        tic
    end
	%}
    
	% add empty neighbourhood to neighbourhood list
	s.neighbourhoods{i} = [];
	s.neighbourhoodScores(i) = 0;
	s.neighbourhoodMaxDistance(i) = +Inf;
	
	% add default gradient (zero-plane)
	s.gradients{i} = zeros(s.outputDimension, s.dimension);
	
	% consider all previously added samples and add a parent link
	for j = 1 : i-1
		
		% add parent link from older sample j to new sample i
		% this will fill up the neighbourhood set of the new sample with
		% relevant, closely spaced neighbours
		s = addParentLink(s, samples, values, j, i);
		
	end
	
	s.logger.finer(sprintf('Added neighbourhood of sample %d', i));
end

% we update our size - we got all samples covered
s.sampleSize = size(values,1);

%{
[xsamples,indices] = sortrows(samples);
xgradients = s.gradients(indices);
xneighbourhoods = s.neighbourhoods(indices);
xgradientErrors = s.gradientErrors(indices);
for i = s.sampleSize+1 : size(values,1)
for i = 1 : size(values,1)
	lsam = length( samples);
	lxsam = length( xsamples);
	lval = size(values,1);
	xi = xneighbourhoods{i};
	s.logger.finer(sprintf('Best neighbours for %s are: %s', arr2str(xsamples(i,:)), arr2str(samples(xneighbourhoods{i},:))));
	s.logger.finer(sprintf('Gradient for %s is: %s', arr2str(xsamples(i,:)), arr2str(xgradients{i})));
	s.logger.finer(sprintf('Gradient error for neighbours is: %s', arr2str(xgradientErrors{i})));
end
%s.logger.fine(sprintf('Voronoi cells for all samples: %s', arr2str(s.voronoi(indices))));


% we update the average gradient error
totalError = 0;
totalNeighbours = 0;
for A = 1 : s.sampleSize
	
	% add every gradient error to the total
	totalNeighbours = totalNeighbours + length(s.neighbourhoods{A});
	for i = 1 : length(s.neighbourhoods{A})
		totalError = totalError + s.gradientErrors{A}(i);
	end
end
for A = 1 : s.sampleSize
	avgError = size(values,1) * sum(s.gradientErrors{indices(A)}) / totalError;
	s.logger.finer(sprintf('Average gradient error for %s is: %d, voronoi cell size is: %d', arr2str(xsamples(A,:)), avgError, s.voronoi(indices(A))));
end

% divide total error by total amount of neighbours (can be grater than the
% number of samples, as one sample can be neighbour for multiple others)
s.averageGradientError = totalError / totalNeighbours;
%s.logger.fine(sprintf('Average gradient error after updating the neighbourhoods: %d', s.averageGradientError));
%}
