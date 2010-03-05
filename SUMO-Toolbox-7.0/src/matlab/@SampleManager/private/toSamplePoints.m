function [s,points] = toSamplePoints(s, p, priorities)

% toSamplePoints (SUMO)
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
%	[s,points] = toSamplePoints(s, p, priorities)
%
% Description:
%	Convert an matrix of sample locations into a cell
%	vector of SamplePoint objects

% create java SamplePoints
points = javaArray('ibbt.sumo.sampleevaluators.SamplePoint', size(p,1));

for i=1:size(p,1)

	% create new sample point object
	newPoint = ibbt.sumo.sampleevaluators.SamplePoint( p(i,:), zeros(s.simulatorOutputDimension,1) );
    
    % set priority
    if ~isempty(priorities)
        newPoint.setPriority(priorities(i));
    end

	% apply unfilter function
	[newPoint] = unfilterInputs(s, newPoint);

	% add to list
	points(i) = newPoint;
end

