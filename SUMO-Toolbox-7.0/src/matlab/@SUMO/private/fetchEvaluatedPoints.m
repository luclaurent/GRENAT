function [s, newSamples, newValues, newIds] = fetchEvaluatedPoints(s)

% fetchEvaluatedPoints (SUMO)
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
%	[s, newSamples, newValues, newIds] = fetchEvaluatedPoints(s)
%
% Description:
%	Fetch all finished simulation points from the SampleEvaluator and
%	handle and filter the different outputs

% Default empty
newSamples = zeros(0, s.simulatorDimension);
newValues = zeros(0, s.flatOutputDimension);
newIds = zeros(0, 1);

% Poll all sample points out of the SampleEvaluator
point = s.sampleEvaluator.fetchEvaluatedSample();
while (point ~= [])
	newSamples(end+1,:) = point.getInputParameters().';
	newValues(end+1,:) = point.getOutputParameters().';
	newIds(end+1,:) = point.getId();
	point = s.sampleEvaluator.fetchEvaluatedSample();
end
