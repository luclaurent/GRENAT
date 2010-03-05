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

% DE passes options structure, disregard that
if isa( arg, 'Model' )
    func = @(x, options) evaluate(arg,x);
else % assume function handle
	func = @(x, options) arg(x);
end

[LB UB] = this.getBounds();
this.options.FVr_minbound = LB;
this.options.FVr_maxbound = UB;

this.options.I_D = this.getInputDimension();
this.options.FM_pop = this.getInitialPopulation();

%Actually run the DE
[x,best,I_nf] = DifferentialEvolution.deopt(func,this.options);
fval = best.FVr_oa;
