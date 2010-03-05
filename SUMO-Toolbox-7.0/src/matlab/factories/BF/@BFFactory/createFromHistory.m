function [s,model] = createFromHistory(s, history )

% createFromHistory (SUMO)
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
%	[s,model] = createFromHistory(s, history )
%
% Description:
%	Creates a sequential interface

[samples values] = getSamples(s);

dimension = getDim(s);
functions = getBasisFunctions(s);

% transform history scores from [0, +Inf] (0 = best) range to [1,0] (1 = best)
% range for further processing
% in case of scores [0 0 ... 0], we convert to perfect score [1 1 ... 1]
history.scores = 1 - history.scores / max(~any(history.scores), norm(history.scores));

BF = struct;
for d=1:dimension
	% Select a random basis function
	%    W: I tried to add intelligence to this before, but it
	%    seemed to be a waste of time
	functionSelect = randomInt(1,length(functions));
	BFSpec = functions(functionSelect);
	BFParams = length(BFSpec.min);

	% Browse through history, selecting old configurations
	historySize = length(history.scores);
	theta = zeros(0,BFParams);
	scores = zeros(0,1);
	tmp = history.models;
	for k = 1:historySize
		x = struct(tmp(k));
		if strcmp( x.config.func(d).name, BFSpec.name )
			theta(end+1,:) = scaleOut( s, x.config.func(d).theta, BFSpec );
			scores(end+1) = history.scores(k);
		end
	end
	
	scoreSum = sum(scores);
	newTheta = zeros(1,BFParams);
	
	if size(theta,1) > 1
		avg = sum( theta .* repmat( scores(:), 1, BFParams ) ) / scoreSum;
	else
		avg = repmat( .5, 1, BFParams );
	end

	if ~isreal( avg )
		error( 'The average is not real!' );
	end

	BF(d).theta = scaleIn( s, avg + randn(1,BFParams) / 16, BFSpec );
	BF(d).name = BFSpec.name;
	BF(d).func = BFSpec.func;
end

% Browse through history, selecting old configurations
historySize = length(history.scores);
regression = zeros(0,1);
tmp = history.models;
for k = 1:historySize
	x = struct(tmp(k));
	regression(k) = x.config.degrees;
end

% Count all occurances of each regression degree, weighting by the scores
possibilities = getRegression(s);
probabilities = zeros(size(possibilities));
for k = 1:length(possibilities)
	probabilities(k) = sum( history.scores( find( possibilities(k) == regression ) ) );
end

% Then pick a random new one, based on the weighted probabilities described above
% Give completely absent possibilities at least some credit...
probabilities = ( .1/length(probabilities) + probabilities ) / (.1+sum(probabilities));
probabilities = cumsum( probabilities );
sel = rand(1);
[x,index] = find( probabilities > sel );
newRegression = possibilities(index(1));

% s is the config used to build the model
modelConfig = struct( ...
	'func',				BF, ...
	'degrees',			newRegression, ...
	'backend',			getBackend(s), ...
	'targetAccuracy',	0.005 ...
);

% And convert it to the correct model class
model = makeModel( s, modelConfig );

