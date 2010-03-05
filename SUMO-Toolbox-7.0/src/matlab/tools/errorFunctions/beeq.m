function e = beeq( a,b )

% beeq (SUMO)
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
%	e = beeq( a,b )
%
% Description:
%	Computes the Bayesian Estimator Error Quotient (BEEQ) between a (true) and b (predicted).
%
%	From: Rong Li and Zhanlue Zhao, Evaluation of estimation algorithms part I: incomprehensive measures of
%	  performance, IEEE Transactions on Aerospace and Electronic Systems, vol. 42, no. 4, pp. 1340-1358, 2006

% the number of datapoints
m = size(a,1);

% the residues
r = abs(a - b) ./ abs(a - repmat(mean(a,1),m,1));

% calculate ln(beeq) for numerical reasons
lnBeeq = sum(log(r),1) ./ m;

% return the actual beeq
e = exp(lnBeeq);
