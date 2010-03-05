function [initialsamples, evaluatedSamples] = generate(s)

% generate (SUMO)
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
%	[initialsamples, evaluatedSamples] = generate(s)
%
% Description:
%	Choose an initial sampleset in such a way that they form a latin
%	hypercube
%	 Implementation based on "Orthogonal-Maximin Latin Hypercube Designs"
%	 by V. Roshan Joseph and Ying Hung

[inDim outDim] = getDimensions(s);

importanceParameters = getImportanceParameters(s);
starttime = clock;

if s.points <= 1
	s.logger.warning(sprintf('Can''t generate a latin hypercube of %d points, generating random set...', s.points));
	initialsamples = rand(s.points, inDim) .* 2 - 1;
	evaluatedSamples = [];
	return;
end

% generate filename for prefab design
type = 'lhd';
metric = 'l2';
filename = sprintf('mm%s%s%id%.3i', metric, type, inDim, s.points);
M3Root = mfilename('fullpath');
M3Root = M3Root(1:end-56);
filePath = sprintf('%s%s%s.txt', M3Root, s.prefabDir, filename);

% Try to load prefab design if possible
if s.prefab
	
	try
		
		initialsamples = load(filePath);
		evaluatedSamples = [];
		s.logger.fine(sprintf('Using pre-calculated latin hypercube design from file %s',filename));
		return;
	catch e 
		% Warning
		% Continue optimizing one
		msg = sprintf( 'Prefab LHD design not available in local cache for %i samples in %i dimensions', s.points, inDim);
		s.logger.warning(msg);
		s.logger.fine(['Prefab error message: ' e.message ]);
	end
end

if s.prefabInternet
	
	% generate string for url
	url = sprintf('http://www.spacefillingdesigns.nl/maximin/lhd%snd.php?n=%d&m=%d', metric, s.points, inDim);
	try
		text = urlread(url);

		% read all numbers, only consider the s.points last ones,
		% the ones before that are from the header
		%numbers = regexp(s, '[0-9]+', 'match');
		%numbers = numbers((end-(s.points*inDim)+1):end);

		% read the lines which contain only numbers and spaces (the matrix)
		numbers = regexp(text, '<TD>([0-9]+)</TD>', 'tokens');

		% construct an array from these
		initialsamples = zeros(s.points, inDim);
        counter = 1;
		for i = 1 : s.points
            for j = 1 : inDim
                initialsamples(i,j) = str2double(numbers{counter}{1});
                counter = counter + 1;
            end
		end

		% rescale them so that they lie in the [-1,1] domain
		initialsamples = initialsamples ./ (s.points-1) .* 2 - 1;
		evaluatedSamples = [];
		
		% save them to disk
		save(filePath, 'initialsamples', '-ascii');
		
		return;
	catch ME
		msg = sprintf( 'Prefab LHD design for %i samples in %i dimensions could not be downloaded automatically', s.points, inDim);
		s.logger.warning(msg);
		s.logger.fine(['Prefab error message: ' e.message ]);
	end
end

if s.statisticsToolbox
	initialsamples = lhsdesign(s.points, inDim, 'criterion', 'maximin', 'iterations', 500, 'smooth', 'on');
	initialsamples = initialsamples .* 2 - 1;
	evaluatedSamples = [];
	return;
end

% Initial LHD
if size(importanceParameters,1) ~= 0
		% Screening
		[initialsamples, gridsize] = latinHypercubeSampleN(importanceParameters, s.points);	
	else
		% No Screening
		[initialsamples, gridsize] = latinHypercubeSample(inDim, s.points);
end

n = s.points; % number of samples
k = inDim; % dimension (number of factors)

% preprocessing
[lb ub] = scaleIntersiteDistance();

comb = (n.*(n-1))./ 2;
Imax = 10.*comb.*k; % number of tries without improvement before temperature is adjusted

[optimalPerformance, rho2, phi] = objectivefunction( initialsamples );
temp = s.initialTemperature;

% current design (not necessarily the best so far)
currentSamples = initialsamples;
currentPerformance = optimalPerformance;
currentRho2 = rho2;
currentPhi = phi;

s.logger.info( sprintf( 'Optimizing Latin Hypercube...' ) );
s.logger.finer( sprintf( 'Initial value for pairwise correlation is %f', pairwiseCorrelation( initialsamples ) ) );
s.logger.finer( sprintf( 'Initial value for intersite distance is %f', intersiteDistance( initialsamples ) ) );
s.logger.finer( sprintf( 'Initial value for criterion is %f', optimalPerformance ) );

% Temperature (outer) loop
tFlag = true;
while tFlag && etime(clock,starttime) < s.maxtime
	tFlag = false;
	iPert = 1;
	% Perturbation (inner) loop
	while iPert < Imax && etime(clock,starttime) < s.maxtime
	
		% generate new design
		% columns with high correlation with respect to other columns have more chance of being selected
		%column = randomInt( 1, k );
		%column = russianRoulette( rho2 ); % TODO alpha
		[dummy, column] = max( currentRho2 );

		% rows that are close to other rows have more chance of being selected
		%e1 = russianRoulette( phi );
		%e1 = randomInt( 1, n ); %
		[dummy, e1] = max( currentPhi );
		e2 = randomInt( 1, n ); % second row is purely random

		% swap elements
		newSamples = currentSamples;
		newSamples(e1, column) = currentSamples(e2, column);
		newSamples(e2, column) = currentSamples(e1, column);	

		% See if it is better than our current design
		[newPerformance, newRho2, newPhi] = objectivefunction( newSamples );
		if newPerformance < currentPerformance
			currentSamples = newSamples;
			currentPerformance = newPerformance;
			currentRho2 = newRho2;
			currentPhi = newPhi;
			tFlag = true;
		else
			prob = exp( -(currentPerformance - newPerformance) ./ temp );
			draw = rand(1);

			if draw < prob
				currentSamples = newSamples;
				currentPerformance = newPerformance;
				currentRho2 = newRho2;
				currentPhi = newPhi;
				tFlag = true;
			end
		end

		% Keep track of best design so far
		if newPerformance < optimalPerformance
			initialsamples = newSamples;
			optimalPerformance = newPerformance;		
			iPert = 1;
		else
			iPert = iPert + 1;
		end
	end
	temp = temp .* s.coolingFactor;
end

s.logger.finer( sprintf( 'Optimal value for pairwise correlation is %g', pairwiseCorrelation( initialsamples ) ) );
s.logger.finer( sprintf( 'Optimal value for intersite distance is %g', intersiteDistance( initialsamples ) ) );
s.logger.finer( sprintf( 'Optimal value for criterion is %f', optimalPerformance ) );
s.logger.finer( sprintf( 'Time needed to find initial design: %f', etime( clock,starttime ) ) );

gridsize=repmat( gridsize, n, 1 );

% scale samples from [1,gridsize] to [0,1]
initialsamples = (initialsamples - 1) ./ (gridsize - 1);
% scale samples from [0,1] to [-1,1]
initialsamples = initialsamples .* 2 .* (1 - 1./gridsize) - (1 - 1./gridsize);

evaluatedSamples = [];

function [perf, rho2, phi] = objectivefunction( samples )
	[pwcorr, rho2] = pairwiseCorrelation( samples );
	
	[interdist, phi] = intersiteDistance( samples );
	interdist = (interdist - lb) ./ (ub - lb);
	
	perf = s.weight.*pwcorr + (1-s.weight).*interdist;
end

% Pairwise correlation performance measure (1994 Owen)
% rho2 = sum of column ij linear correlations divided by dim(dim-1)/2
% linear correlation: r_XY = cov_XY / (S_X*S_Y) = SS_XY / (SS_X * SS_Y)
% SS = sum of squres
function [out, rho2] = pairwiseCorrelation( samples )
	% correlation is useless in 1 dimension
	if k == 1
		out = 1;
		rho2 = 1;
		return
	end

	%c = corr(samples); % from statistics toolbox, can't use it
	c = corrcoef(samples);
	c = c.*c;
	
	% correlation for the design matrix
	out = 0;
	for i=2:k
		for j=1:i-1
			out = out + c(i,j);
		end
	end
	out = out ./ (k.*(k-1)./2);
	
	% correlation per column (with respect to all other columns)
	rho2 = sum(c, 2) - 1; % subtract the correlation coeff. with itself (-1) 
	rho2 = rho2 ./ (k-1); % avg over all columns except itself
end

% maximin performance measure (1995 Morris and Mitchell)
% or inter-site distance, extended version
function [out, phi] = intersiteDistance( samples )
	% n*(n-1) / 2 pairwise distances (combinatorial: pick 2 points from n
	% with no repetitions and order doesn't matter)
	%D = pdist( samples, 'cityblock' );
	D = buildManhattanDistanceMatrix(samples, samples, true);
	D = 1./(D.^s.p);
	
	% distance measure the design matrix
	out = sum(D).^(1./s.p);
	
	% distance measure per column (with respect to all other columns)
	D = squarify(D);
	phi = sum(D, 2).^(1./s.p);
end

function [lb, ub] = scaleIntersiteDistance()
	% avg. intersite distance
	d = k.*(n+1) ./ 3;
	cd = ceil(d);
	fd = floor(d);
	
	% lowerbound
	comb = (n.*(n-1))./ 2;
	lb = (comb.* ((cd - d) ./ fd.^s.p + (d - fd) ./ cd.^s.p)).^(1./s.p);
	
	% upperbound
	i = 1:(n-1);
	ni = n - i;
	ik = i .* k;
	ub = sum(ni ./ ik.^s.p) .^(1./s.p);
end

end


