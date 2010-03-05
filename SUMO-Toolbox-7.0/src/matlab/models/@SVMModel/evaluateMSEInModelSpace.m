function mse = evaluateMSEInModelSpace(this, points)

% evaluateMSEInModelSpace (SUMO)
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
%	mse = evaluateMSEInModelSpace(this, points)
%
% Description:
%	Evaluation of prediction variance at a set of points

if(strcmp(this.config.backend,'lssvm'))
    try
        mse = bay_errorbar(this.svm, points ); % standard deviation
        mse = mse.*mse; % variance
    catch e
        msg = sprintf('%s (lssvm) does not support support point-wise error estimation for multiple outputs.',class(this));
        error(msg);
    end
else
	error('%s (%s) does not support point-wise error estimation.',class(this),this.config.backend);
end
