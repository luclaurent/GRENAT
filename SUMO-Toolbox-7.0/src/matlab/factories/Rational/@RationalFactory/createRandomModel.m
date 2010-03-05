function model = createRandomModel( s );

% createRandomModel (SUMO)
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
%	model = createRandomModel( s );
%
% Description:
%	Creates a random rational model

[smp val] = getSamples(s);
percent = s.percent;
weight = s.weight;

% Whats the maximum percentage we can set so that we do not exceed the maximum absolute bound
maxPerc = round((s.maxDegrees / size(smp,1)) * 100);

% enforce the maximum
percent.upper = min(percent.upper, maxPerc);

[ni no] = getDimensions(s);

percentage = randomInt( percent.lower, percent.upper );
weights = zeros(1,ni);
for k=1:ni
	weights(k) = randomInt( weight.lower(k), weight.upper(k) );
end
flags = rand(1,ni) > s.rational/100;

model = s.createModel( [percentage, fix( weights ), fix( flags )] );
