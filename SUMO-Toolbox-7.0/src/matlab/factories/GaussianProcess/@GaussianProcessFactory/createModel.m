function m = createModel(this, individual)

% createModel (SUMO)
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
%	m = createModel(this, individual)
%
% Description:
%	Given an individual representing a model, return a real model

%Construct the model through the given samples

if(~exist('individual','var') || isempty(individual))

  if isempty( [this.lowerThetaBounds;this.upperThetaBounds] )
	m = GaussianProcessModel(this.initialTheta, this.regrFunction,this.covFunction,[]);
  else
	m = GaussianProcessModel(this.initialTheta, this.regrFunction,this.covFunction, [this.lowerThetaBounds;this.upperThetaBounds]');
  end

elseif(isa(individual,'Model'))

	m = individual;

else
	m = GaussianProcessModel(individual,this.regrFunction,this.covFunction,[]);
end
