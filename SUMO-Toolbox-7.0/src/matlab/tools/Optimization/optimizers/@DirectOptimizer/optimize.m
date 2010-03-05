function [this, x, fval] = optimize(this, arg)

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
%	[this, x, fval] = optimize(this, arg)
%
% Description:
%	This function optimizes the given function handle

import DIRECT.*;

if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x');
else % assume function handle
	func = @(x) arg( x' );
end

problem = struct( 'f', func );
problem.numconstraints = length(this.constraints);
for i=1:length(this.constraints)
	cons = this.constraints{i};
	fcons = @(x) evaluate( cons, x' );
	
	problem.constraint(i).func = fcons;
	problem.constraint(i).penalty = this.penalty;
end

% DIRECT expects nx2 vector
[LB, UB] = this.getBounds();
bounds = [LB' UB'];

%[fval,newOptimums,history] = Direct(Problem,bounds,opts);
[fval,x,history] = Direct( problem, bounds, this.opts );
x=x';

