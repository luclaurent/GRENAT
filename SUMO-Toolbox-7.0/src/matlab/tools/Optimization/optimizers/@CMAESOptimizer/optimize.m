function [this, x, fval] = optimize(this, arg )

% optimize (SUMO)
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
%	[this, x, fval] = optimize(this, arg )
%
% Description:
%	This function optimizes the given function handle

import cmaes.*;

if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x');
else % assume function handle
	func = @(x) arg( x' );
end

% CMA-ES expects bounds as column vectors
[LB UB] = this.getBounds();
this.opts.LBounds = LB(:);
this.opts.UBounds = UB(:);

if(this.sigma < 0)
	[LB UB] = this.getBounds();
	this.sigma = (UB(:) - LB(:)) ./ 3;
end


[x,fval,cnteval,stopflag,out,bestever] = cmaes( func, this.getInitialPopulation()', this.sigma, this.opts );
x=x';

