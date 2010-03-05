function res = createInitialModels(s, number, wantModels);

% createInitialModels (SUMO)
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
%	res = createInitialModels(s, number, wantModels);
%
% Description:
%	Constructor

%Get the default config (from config file)
res = [];
[smp val] = getSamples(s);
[numIn numOut] = getDimensions(s);

weightBounds = s.weight;
percentBounds = s.percent;

% Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
maxPerc = (s.maxDegrees / size(smp,1)) * 100;

% enforce the maximum
percentBounds.upper = min(percentBounds.upper, maxPerc);

% Assume an individual is a vector as follows [percent weights flags]
% Return a random population (TODO: more intelligent?)

params = zeros(number,1+numIn+numIn);

for i=1:number
  % random percentage
  range = percentBounds.upper - percentBounds.lower;
  percent = rand(1) * range + percentBounds.lower;
  
  % random weights
  range = weightBounds.upper - weightBounds.lower + 1;
  weights = fix( rand(1,numIn) .* range ) + weightBounds.lower;

  % Random flags
  flags = rand(1,numIn) > (s.rational / 100);

  params(i,:) = [percent weights flags];
end

if(wantModels)
    % Pre-allocate the population
    res = repmat(RationalModel(),number,1);

    for i=1:number
	     res(i,1) = s.createModel(params(i,:));
    end
else
    res = params;
end

s.logger.fine( sprintf( 'Created %d Rational models', number ) );
