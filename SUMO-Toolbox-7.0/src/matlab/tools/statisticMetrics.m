function [m stdd mediann madd] = statisticMetrics( d )

% statisticMetrics (SUMO)
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
%	[m stdd mediann madd] = statisticMetrics( d )
%
% Description:
%	Calculate some interesting metrics from statistics

if size( d, 1 ) > size( d, 2 )
	d = d.';
end

% Check each matrices has same number of columns
maxLength = -Inf;
colSize = size(d{1},2);

for i=1:length(d)
	if(size(d{i},2) ~= colSize)
		error('All matrices must have the same number of columns')
	end

	if(size(d{i},1) > maxLength)
		maxLength = size(d{i},1);
	end
end

% calculate some measures
colSize = size( d{1}, 2 );
res2 = cell2mat(d);
for i=1:colSize
	% measure of scale
	stdd(:,i) = std(res2(:,i:colSize:end),0,2);	% the std deviation
	madd(:,i) = mad(res2(:,i:colSize:end),0,2); % robust (median of absolute deviation)
	
	% measure of location
	mediann(:,i) = median(res2(:,i:colSize:end),2); % median
	m(:,i) = mean(res2(:,i:colSize:end),2); % mean
end
