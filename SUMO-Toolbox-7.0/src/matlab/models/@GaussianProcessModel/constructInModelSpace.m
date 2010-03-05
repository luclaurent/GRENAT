function this = constructInModelSpace(this, samples, values)

% constructInModelSpace (SUMO)
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
%	this = constructInModelSpace(this, samples, values)
%
% Description:
%	Just sets all members to new samples and values

this = this.constructInModelSpace@Model(samples, values);

% No construction is needed. model == theta

% Availale covFuncs:
%   covConst.m      - covariance for constant functions
%	- 1 parameters
%   covLINard.m     - linear covariance function with ard
%	- dim parameters
%   covLINone.m     - linear covariance function
%	- 1 parameter
%   covMatern3iso.m - Matern covariance function with nu=3/2
%	- 2 parameters
%   covMatern5iso.m - Matern covariance function with nu=5/2
%	- 2 parameters
%   covNNone.m      - neural network covariance function
%	- 2 parameters
%   covNoise.m      - independent covariance function (ie white noise)
%	- 1 parameter
%   covPeriodic.m   - covariance for smooth periodic function with unit period
%	- 2 parameters
%   covRQard.m      - rational quadratic covariance function with ard 
%	- dim+2 parameters
%   covRQiso.m      - isotropic rational quadratic covariance function
%	- 3 parameters
%   covSEard.m      - squared exponential covariance function with ard
%	- D+1 parameters
%   covSEiso.m      - isotropic squared exponential covariance function
%	- 2 parameters

end
