function s = setData(s, state)

% setData (SUMO)
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
%	s = setData(s, state)
%
% Description:
%	Set the data point (samples and values) on the ModelBuilder object

s.state = state;

samples = state.samples;
values = state.values;

% Look for new minimum(s)
% Is there any new minimum that satisfy all constraints
minimumProfilerData = zeros( 1, size(values,2)+1);
minimumProfilerData(1) = size(samples,1);

for i=1:size(values,2)
	% Find current minimum of this output
	[minimumProfilerData(i+1), indexNew] = findMinimum( samples, values(:,i) );
end

% update profiler
s.minimumProfiler.addEntry( minimumProfilerData );
end
