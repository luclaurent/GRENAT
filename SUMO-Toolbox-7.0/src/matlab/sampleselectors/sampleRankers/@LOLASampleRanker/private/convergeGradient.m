 function newGradient = convergeGradient(s, samples, values, A, outputIndex, oldGradient)

% convergeGradient (SUMO)
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
%	newGradient = convergeGradient(s, samples, values, A, outputIndex, oldGradient)
%
% Description:
%	Converge the gradient plane of A to its neighbours.

%s.logger.finer(sprintf('Converging gradient plane of %d to neighbours', A));

% use the iterative Least Means Square (LMS) method - incompatible with complex outputs!
% O(N)
if strcmp(s.gradientMethod, 'iterative')

	% repeat the iteration a couple of times
	ITERATIONS = 5;
	for it = 1 : ITERATIONS

		% converge by a rate proportional to the number of neighbours
		N = length(s.neighbourhoods{A});

		% slowly converge the gradient plane to the location of each neighbour
		newGradient = oldGradient;
		corr = zeros(size(samples,2),1);
		for i = 1 : length(s.neighbourhoods{A})

			% we consider P
			P = s.neighbourhoods{A}(i);

			% L = diff between P and A
			L = samples(P,:) - samples(A,:);

			% delta(v) = diff between func(P) and func(A)
			dv = values(P,outputIndex) - values(A,outputIndex);

			% error
			e = dv - dot(s.gradients{A},L);

			% correction
			corr = corr + L .* e ./ dot(L,L) .* (1/2/it); % was 1/N

		end

		% update plane after each iteration
		newGradient = newGradient + corr;
	end

	%s.logger.finer(sprintf('Gradient plane converged to %s', arr2str(s.gradients{A})));
	
% use the direct method
% O(N?) ?
%elseif strcmp(s.gradientMethod, 'direct')
else
	
	% we solve ax = b using the least-squares method
	
	% construct a, translate A to the origin
	%a = bsxfun(@minus, samples(s.neighbourhoods{A},:), samples(A,:))
	sA = samples(A,:);
	a = samples(s.neighbourhoods{A},:) - sA(ones(length(s.neighbourhoods{A}),1), :);
	
	% construct b
	b = values(s.neighbourhoods{A},outputIndex) - values(A,outputIndex);
	
	% calculate the gradient
	newGradient = a \ b;
end
