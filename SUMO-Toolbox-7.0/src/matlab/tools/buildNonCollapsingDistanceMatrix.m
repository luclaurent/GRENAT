function distances = buildNonCollapsingDistanceMatrix(samples, targets)

% buildNonCollapsingDistanceMatrix (SUMO)
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
%	distances = buildNonCollapsingDistanceMatrix(samples, targets)
%
% Description:
%	Calculate the

% calculate the distance
Xt = permute(samples, [1 3 2]);
Yt = permute(targets, [3 1 2]);
%distances = sqrt(sum(abs( Xt(:,ones(1,size(targets,1)),:) - Yt(ones(1,size(samples,1)),:,:) ).^2, 3))
distances = min(abs( Xt(:,ones(1,size(targets,1)),:) - Yt(ones(1,size(samples,1)),:,:) ), [], 3);
