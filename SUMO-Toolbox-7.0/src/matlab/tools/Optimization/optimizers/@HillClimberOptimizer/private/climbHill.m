function [xMin, fMin] = climbHill(this, xStart, f)

% climbHill (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[xMin, fMin] = climbHill(this, xStart, f)
%
% Description:
%	Perform a hill climb, starting from xStart, and return the local
%	minimum xMin with function value fMin.

% initial variables
startTime = clock;
it = 1;

% initial point
xMin = xStart;
fMin = f(xMin);

% step taken at each iteration
step = this.step;

% dimensions
inDim = this.getInputDimension();
outDim = this.getOutputDimension(); % not used!

% keep going until we have reach the max # of iterations, or the time limit
while it <= this.maxIterations && etime(clock, startTime) < this.timeLimit
	
	% take a step in each direction
	xNew = bsxfun(@plus, xMin, [-eye(inDim) * step ; eye(inDim) * step]);
	
	% do not cross the boundaries!
	xNew = max(-1, min(1, xNew));
	
	% evaluate all the values
	fNew = f(xNew);
	
	% take the steepest step
	[~, indices] = sort(fNew - fMin);
	bestStep = indices(1);
	
	% if the steepest step is worse or equal to the current position, abort
	if fNew(bestStep) >= fMin
		return;
	end
	
	% calculate the step direction
	stepDirection = xNew(bestStep,:) - xMin;
	
	% we have improvement - update xMin and fMin
	xMin = xNew(bestStep,:);
	fMin = fNew(bestStep);
	
	% now move in the same direction a number of steps, until no further
	% improvement can be made
	for i = 1 : this.lineSteps
		
		% calculate xNew, take into account the border
		xNew = max(-1, min(1, xMin + stepDirection));
		
		% calculate fNew
		fNew = f(xNew);
		
		% no further improvement, abort
		if fNew >= fMin
			break;
		end
		
		% else, move up one more step in the same direction
		xMin = xNew;
		fMin = fNew;
		
	end
	
	% next iteration
	it = it + 1;
end

% we've done our best, the best choice so far is already in xMin,fMin


end

