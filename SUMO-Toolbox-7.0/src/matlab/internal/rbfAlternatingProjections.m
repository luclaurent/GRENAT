function coefficients = rbfAlternatingProjections( samples, values, kernel, theta, target, clustersize )

% rbfAlternatingProjections (SUMO)
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
%	coefficients = rbfAlternatingProjections( samples, values, kernel, theta, target, clustersize )
%
% Description:
%

nSamples = size(samples,1);

clusters = cell(0);

switch 2
case 0
	bounds = linspace( -1,1,fix(nSamples / clustersize)+2 );
	boxstep = bounds(2) - bounds(1);
	delta = boxstep / 10;
	
	for k=1:length(bounds)-1
		clusters{end+1} = find( (samples(:,1) > (bounds(k) - delta)) & (samples(:,1) < (bounds(k+1) + delta) ) )';
	end
	
	nClusters = length(clusters);
case 1
	per = randperm( nSamples );
	overlap = max( 5, clustersize / 20 );
	
	start = 1;
	while start+clustersize <= nSamples
		stop = start+clustersize;
		clusters{end+1} = per(start:stop);
		start = stop - overlap + 1;
	end
	
	lastSamples = per( (start+overlap-1):end );
	nClusters = length(clusters);

	nPer = ceil(length(lastSamples)/nClusters);
	for i=1:nClusters
		clusters{i} = [clusters{i} lastSamples(1:nPer)];
		lastSamples(1:nPer) = [];
		nPer = min( length(lastSamples), nPer );
		if nPer == 0
			break
		end
	end
case 2
	d = size(samples,2);
	
	blocks = nSamples / clustersize;
	bPerDim = floor( blocks ^ (1/d) );
	
	k = 0;
	while 1
		if (bPerDim+1) ^ k * bPerDim ^ (d-k) > blocks
			break
		end
		k = k+1;
	end
	
	blocks = [ ones(k,1) * (bPerDim+1); ones(d-k,1) * bPerDim ];
	delta = (2./blocks)/5;
	
	clusters = { 1:nSamples };
	
	% Now divide samples over the blocks
	for k=1:d
		bounds = linspace(-1,1,blocks(k)+1);
		newclusters = {};
		for l=1:length(clusters)
			c = clusters{l};
			for j=1:blocks(k)
				tmp = find( ...
					(samples(c,k) > bounds(j)   - delta(k)) & ...
					(samples(c,k) < bounds(j+1) + delta(k)) );
				newclusters{end+1} = c(tmp);
			end
		end
		clusters = newclusters;
	end
	nClusters = length(clusters);
end

%  disp( sprintf( '%d clusters constructed of minimal size %d', nClusters, clustersize ) );

residues = values;
coefficients = zeros(nSamples,1);
maxiter = 50;

for iter=1:maxiter
%  	disp( sprintf( 'Iteration %d, max error %f', iter, max(abs(residues) ) ) );
	for c=1:nClusters
		cluster = clusters{c};
		distanceMatrix = buildDistanceMatrix(samples(cluster,:),samples);
		rbfmatrix = feval( kernel, distanceMatrix, theta );
		coeff = rbfmatrix(:,cluster) \ residues(clusters{c});
		residues = residues - rbfmatrix' * coeff;
		coefficients(cluster) = coefficients(cluster) + coeff;
		
%  		disp( sprintf( '  - Cluster %d, max error is %f', c, max(abs(residues)) ) );
	end
	
	if max(abs(residues)) < target
		break
	end
end

%disp( sprintf( 'Done (M=%f,RMS=%f)!', max(abs(residues)), rms(residues)) )
