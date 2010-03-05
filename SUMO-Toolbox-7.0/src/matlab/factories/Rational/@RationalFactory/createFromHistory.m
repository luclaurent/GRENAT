function [this,model] = createFromHistory(this, history)

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
%	[this,model] = createFromHistory(this, history)
%
% Description:
%	Create a new rational model based on the history of models built previously
%

[samples values] = getSamples(this);
[numIn numOut] = getDimensions(this);

% transform history scores from [0, +Inf] (0 = best) range to [1,0] (1 = best)
% range for further processing
% in case of scores [0 0 ... 0], we convert to perfect score [1 1 ... 1]
history.scores = 1 - history.scores / max(~any(history.scores), norm(history.scores));

percent = this.percent;
weight = this.weight;
rational = this.rational;

% Extract model config from history
historyLength = length(history.scores);
weights = zeros(0,numIn);
percentage = zeros(historyLength,1);
flags = zeros(0,numIn);

for k=1:historyLength
	[percentage(k), weights(k,:), flags(k,:)] = getParameters( history.models(k) );
end

% Update rational models average factors...
% (weights, flags & percentage)

% Sum scores
scoreSum = sum( history.scores );

% New weights
range = weight.upper - weight.lower;
if historyLength > 0
	% sum all weights
	weights = reshape( weights, historyLength, numIn );
	if historyLength == 1
		average = weights;
	else
		average = sum( weights .* ...
			repmat( history.scores, 1, numIn ) );
		average = average / scoreSum;
	end
else
	% just take middle of interval
	average = weight.lower + range/2;
end

%  disp( sprintf( '[I] Average weights : %s', num2str( average ) ) );

% TODO : Magical number
rnd = randn( 1, numIn ) .* max(4,range/8);
weights = round( rnd + average );
x = find( weights < weight.lower );
weights(x) = weight.lower(x);
x = find( weights > weight.upper );
weights(x) = weight.upper(x);

% New percentsamples
range = percent.upper - percent.lower;
if historyLength > 1
	average = sum( percentage .* history.scores ) / scoreSum;
else
	average = percent.lower + range / 2;
end

rnd = randn(1) * range / 3;
percents = average + rnd;

% make sure the percentage stays within the bounds
if percents < percent.lower
	percents = percent.lower;
elseif percents > percent.upper
	percents = percent.upper;
end

% also make sure the percentage respects the absolute maximum degrees of freedom
% how many samples do we have now
nsamples = size(samples,1);
% Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
maxPerc = (getMaxDegrees(this) / nsamples) * 100;
% enforce the maximum
percents = min(percents, maxPerc);

% New rational flags
if historyLength
	flags = reshape(flags, historyLength, numIn);
	if historyLength > 1
		average = sum( flags .* ...
			repmat(history.scores, 1, numIn));
	
		average = average / scoreSum;
	else
		average = flags;
	end
else
	average = rational / 100;
end

flags = round(average);
rnd = find(rand(size(flags)) > .8);
if length(rnd) > 0
	flags(rnd) = rand(1,length(rnd)) > (rational(rnd) / 100);
end

% And construct the model
model = RationalModel( percents, fix(weights), fix(flags), this.frequencyVariable, this.baseFunction, 0 );
