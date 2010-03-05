function [centers,coefficients] = rbfMultiPointGreedy( samples, values, kernel, theta, target, points )

% rbfMultiPointGreedy (SUMO)
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
%	[centers,coefficients] = rbfMultiPointGreedy( samples, values, kernel, theta, target, points )
%
% Description:
%

nSamples = size(samples,1);
kernelAt0 = feval( kernel, 0, theta );

coefficients = zeros(size(samples,1),1);
maxres = max(abs(values));

maxiter = 50*nSamples;
i=1;
while (maxres > target) & (i<maxiter)
	nonzeroes = find( abs(coefficients) > eps );
	[dummy,index] = max(abs(values));
	[sorted,indices] = sort(values(nonzeroes),'descend');
	ks = [index; nonzeroes(indices(1:min(length(indices),points)))];
	ks = unique(ks);
	distances = buildDistanceMatrix( samples(ks,:) );
	kernelValues = feval( kernel, distances, theta );
	beta = kernelValues \ values(ks);
	for t=1:100:length(samples)
		s = min( length(samples),t+99 );
		distances = buildDistanceMatrix( samples(t:s,:), samples(ks,:) );
		kernelValues = feval( kernel, distances, theta );
		values(t:s) = values(t:s) - kernelValues * beta;
	end
	coefficients(ks) = coefficients(ks) + beta;
	maxres = max(abs(values));
	i=i+1;
%  	disp( sprintf( 'M=%f,RMS=%f,nCenters=%d)!', ...
%  		max(abs(values)), rms(values), length( find( abs(coefficients) > eps ) ) ) )
end

indices = find( abs(coefficients) > eps );
centers = samples( indices,: );
coefficients = coefficients( indices );

%  disp( sprintf( 'Done (M=%f,RMS=%f,nCenters=%d/%d)!', max(abs(values)), rms(values), length( coefficients ), nSamples) )
