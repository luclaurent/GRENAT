function [badIndices, numInvalid] = removeInvalidValues(s, newSamples, newValues)

% removeInvalidValues (SUMO)
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
%	[badIndices, numInvalid] = removeInvalidValues(s, newSamples, newValues)
%
% Description:
%	Remove Inf and NaN values that were returned by the simulator. These do
%	not belong in the toolbox, because you can't model them.

% check for bad input values (NaN)
badIndices = find(any(isnan(newSamples), 2));


% check for strange values
if any(any(isnan(newValues)))
	%s.logger.warning(sprintf('%d NaN samples %s received from simulator', length(find(any(isnan(newValues),2))), arr2str(unfilteredSamples(find(any(isnan(newValues),2)),:))));
	for i = 1 : length(s.ignoreNaN)
		if s.ignoreNaN(i)
			badIndices = [badIndices ; find(isnan(newValues(:,i)))];
		end
	end
end

if any(any(isinf(newValues)))
	%s.logger.warning(sprintf('%d Inf samples %s received from simulator', length(find(any(isinf(newValues),2))), arr2str(unfilteredSamples(find(any(isinf(newValues),2)),:))));
	for i = 1 : length(s.ignoreInf)
		if s.ignoreInf(i)
			badIndices = [badIndices ; find(isinf(newValues(:,i)))];
		end
	end
end

numInvalid = length(badIndices);
