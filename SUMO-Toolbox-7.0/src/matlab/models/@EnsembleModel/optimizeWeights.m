function s = optimizeWeights( s )

% optimizeWeights (SUMO)
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
%	s = optimizeWeights( s )
%
% Description:
%	Find a better ensemble weighting

ystart = rootMeanSquareError(evaluate(s,getSamples(s)), getValues(s));

	function y = fitness(x);
		s = setWeights(s,x);
		% TODO: simply minimize the training error, warning danger of overfitting!
		y = rootMeanSquareError(evaluate(s,getSamples(s)), getValues(s));
		% add a penalty to prevent one member from dominating at the cost of others (TODO:good idea?)
		%y = y + sum(1 ./ s.weights);
	end

do = DirectOptimizer(length(s.weights),1);
do = setBounds(do,zeros(1,length(s.weights)),ones(1,length(s.weights)));
do = setInitialPoint(do,s.weights);
[do x fval] = optimize(do,@fitness);
s = setWeights(s,x);

disp(sprintf('Starting objective: %d, ending objective: %d, improvement: %d %%',ystart,fval,abs((fval-ystart/ystart) * 100)));

end
