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

if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x);
else % assume function handle
	func = arg;
end

% Honor hints, only supports maxTime
this.opts = optimset(this.opts,'MaxTime', this.getHint( 'maxTime' ) );

[LB, UB] = this.getBounds();
%Actually run the the optimization routine
if ~isempty(LB) && ~isempty(UB)
	opts = optimset(@fmincon);
	opts = optimset( opts, this.opts );
	[x,fval,exitflag,output] = fmincon(func, this.getInitialPopulation(), [], [], this.Aineq, this.Bineq, LB, UB, this.nonlcon, opts);
else
	opts = optimset(@fminunc);
	opts = optimset( opts, this.opts );
	[x fval exitflag output] = fminunc(func, this.getInitialPopulation(), opts);

end
