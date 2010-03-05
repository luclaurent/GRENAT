function [s, bestxMin, bestfMin] = optimize(s, arg)

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
% Revision: $Rev$
%
% Signature:
%	[s, bestxMin, bestfMin] = optimize(s, arg)
%
% Description:
%	This function optimizes the given function handle

if isa( arg, 'Model' )
    func = @(x) evaluate(arg,x);
else% assume function handle
	func = arg;
end

% initial 2 samples are always the same - the 2 corner points
inDim = s.inDim;

% options
options = psoptimset(@patternsearch);
options = psoptimset(options, 'Display', 'off');

options = psoptimset(options, 'Vectorize', 'on');
options = psoptimset(options, 'CompletePoll', 'on');
options = psoptimset(options, 'CompleteSearch', 'on');


% get the initial population
pop = s.getInitialPopulation();

% get the state
state = s.getState();

% for each candidate - optimize towards non-collapsing
bestfMin = +Inf;
for i = 1 : size(pop,1)

	% get the maximin distance of this point
	maximin = state.maximinDistance(i);

	% only diverge a limited amount from the optimal maximin value
	dMax = maximin * s.deviation;

	% define the lower and upper bounds
	x = pop(i,:);
	LB = max(x - (dMax / 2), -ones(1, inDim));
	UB = min(x + (dMax / 2), ones(1, inDim));

	% if it does not violate the noncollapsing rule, just take the point
	%{
	f = func(x);
	if f < 0
		bestxMin = x;
		bestfMin = f;
		return;
	end
	%}

	% now scale the function so that the viable area lies within [-1,1]
	%scaleFunc = @(x)(func((x+1)./ 2 .* (UB-LB) + LB));
	scaleFunc = @(x)(func(bsxfun(@plus, bsxfun(@times, (x+1)./ 2, UB-LB), LB)));

	%disp(sprintf('Started with %s: %d', arr2str(x), f));
	%disp(sprintf('Searching between %s and %s', arr2str(LB), arr2str(UB)));

	% optimize with pattern search in this cube
	%[x, f] = patternsearch(scaleFunc, x, [], [], [], [], -ones(inDim,1), ones(inDim,1), @(x)(s.unitCircleConstraint(x)), options);
	[x, f] = patternsearch(scaleFunc, x, [], [], [], [], -ones(inDim,1), ones(inDim,1), options);

	% scale x back to [LB,UB]
	x = (x+1)./ 2 .* (UB-LB) + LB;

	%disp(sprintf('After optimization %s: %d', arr2str(x), f));
	if f < bestfMin
		bestfMin = f;
		bestxMin = x;
	end

end
	
end
