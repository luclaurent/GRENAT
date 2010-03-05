function [m stdd mediann madd] = interpolatedMean( d )

% interpolatedMean (SUMO)
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
%	[m stdd mediann madd] = interpolatedMean( d )
%
% Description:
%	Calculate the mean and std of a set of matrices with different number of rows (each matrix has the same number of columns)
%	Linearly interpolate them on a fine grid and calculate the mean (per column) on that.

% Find the maximum length of each column
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

% resolution over which to interpolate
resolution = maxLength;

res = cell(1,length(d));
tmp = zeros(maxLength,colSize);
tmp2 = zeros(maxLength,colSize);
m = zeros(maxLength,colSize);

for i=1:length(d)
	tmp = d{i};
	newlen = maxLength - size(tmp,1);
	padded = [tmp ; ones(newlen, colSize) .* repmat(tmp(end,:),newlen,1)];
	
	res{i} = padded;
end

% now all matrices in res have the same number of rows
% create a common interpolation per column

% create the grid over which to interpolate
grid = linspace(1,maxLength,maxLength);
for j=1:length(res)
    tmp = res{j};

    r = zeros(maxLength,colSize);
    for i=1:size(tmp,2)
        % perform the interpolation
        r(:,i) = interp1(tmp(:,i),grid);
    end
    
    res{j} = r;
end

% calculate the std deviation
res2 = cell2mat(res);
stdd = zeros(maxLength,colSize);
madd = zeros(maxLength,colSize);
mediann = zeros(maxLength,colSize);
m = zeros(maxLength,colSize);

for i=1:colSize
	% measure of scale
	stdd(:,i) = std(res2(:,i:colSize:end),0,2);	% the std deviation
	madd(:,i) = mad(res2(:,i:colSize:end),0,2); % robust (median of absolute deviation)
	
	% measure of location
	mediann(:,i) = median(res2(:,i:colSize:end),2); % median
	m(:,i) = mean(res2(:,i:colSize:end),2); % mean
end
