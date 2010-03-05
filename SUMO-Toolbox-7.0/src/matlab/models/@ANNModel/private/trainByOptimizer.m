function net = trainByOptimizer(net, samples, values, op)

% trainByOptimizer (SUMO)
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
%	net = trainByOptimizer(net, samples, values, op)
%
% Description:
%	Trains a Neural Network using the the given Optimizer object

%  net.trainParam.epochs = 100;
%  net.trainParam.showWindow = false;
%  net = train(net,samples,values);
%  figure(1);plot(sim(net,samples));

xstart = getx(net);

%  figure(2);plot(xstart)

if(~exist('op','var'))
	op = DirectOptimizer(length(xstart),1);
end
	
op = setBounds(op,ones(1,length(xstart))*-5,ones(1,length(xstart))*20);
op = setInitialPoint(op,xstart);
ctr = 0;
	
[op x fval] = optimize(op,@fitness);

	function score = fitness(weights);
		net = setx(net,weights);
		vals = sim(net,samples);
		err = mse(vals' - values');
		%Add regularization term
		alpha = 0.5;
		score = alpha*err + ((1-alpha)*sum(weights.^2));
%  		figure(3);plot(vals);
%  		figure(4);plot(weights)
%  		drawnow
		ctr = ctr + 1;
	end

disp(sprintf('Training terminated after %d function evaluations with final score: %d',ctr,fval));
net = setx(net,x);

end
