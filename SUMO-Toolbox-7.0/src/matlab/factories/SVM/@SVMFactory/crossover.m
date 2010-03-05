function xoverKids = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)

% crossover (SUMO)
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
%	xoverKids = crossover(s,parents, options, nvars, FitnessFcn, unused,thisPopulation)
%
% Description:
%	A Simple crossover operator
%	The arguments to the function are
%	 * parents — Row vector of parents chosen by the selection function
%	 * options — options structure
%	 * nvars — Number of variables
%	 * FitnessFcn — Fitness function
%	 * unused — Placeholder not used
%	 * thisPopulation — Matrix representing the current population.
%	The number of rows of the matrix is Population size and the number of columns is Number of variables.

% How many children to produce?
nKids = length(parents)/2;

%Pre-allocate childern array
xoverKids = cell(nKids,1);

% get the samples
[smp val] = getSamples(s);

index = 1;
for i=1:nKids
	% get parents
	parent1 = thisPopulation{parents(index),:};
	index = index + 1;
	parent2 = thisPopulation{parents(index),:};
	index = index + 1;

	%Consider only the regularization and kernel parameters
	p1 = [getRegParam(parent1) getKernelParam(parent1)];
	p2 = [getRegParam(parent2) getKernelParam(parent2)];

	%If the two parents are equal simply add some jitter
	if(p1 == p2)
		p1 = p1 + randn(1,2);
		p2 = p2 + randn(1,2);
	end

	if(rand >= 0.6)
		%Single point crossover + small perturbation
		rp = p1(1) + randn;
		kp = p2(2) + randn;
	else
		%Take the average of the two parents
		rp = (p1(1) + p2(1)) / 2;
		kp = (p1(2) + p2(2)) / 2;

		if(strcmp(getKernel(s),'poly'))
			kp = max(1,round(kp));
		end
	end	

	m = s.createModel([kp rp]);
	xoverKids{i,1} = m;	
end

% Make sure all are trained
xoverKids = constructModels(xoverKids,smp,val,s.getParallelMode());

s.logger.fine(sprintf('Produced %d of %d svm crossover children',nKids,length(thisPopulation)));
