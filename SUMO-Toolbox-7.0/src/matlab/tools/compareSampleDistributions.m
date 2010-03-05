function [means stds] = compareSampleDistributions(dists,nbins);

% compareSampleDistributions (SUMO)
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
%	[means stds] = compareSampleDistributions(dists,nbins);
%
% Description:
%	Given n sample distributions (only 2D supported for now), calculate
%	a histogram of their means and standard deviations.  This is useful
%	if you want to see if the final distribution of points generated by a
%	sample selection algorithm varies a lot across runs
%
%	inputs: dists: cell arry of matrices
%	        nbins: number of bins to use in each dimension (defaults to
%	        11)

if(~exist('nbins','var'))
    nbins = 11;
end

% create some random data for testing
%dists = {};
%for i=1:10
%    dists{i} = rand(200,2);
%end

data = zeros(nbins,nbins,length(dists));

for i=1:length(dists)

    d = dists{i};
    %figure
    %plot(d(:,1),d(:,2),'b+')
    [n x y] = hist2d(d(:,1),d(:,2),nbins);
    
    data(:,:,i) = n;
end

means = mean(data,3);
stds = std(data,0,3);

subplot(1,2,1)
%bar3(means)
imagesc(x(1,:),y(:,1),means);
axis xy;
title('Mean','FontSize',14)
colorbar

subplot(1,2,2)
%bar3(stds)
imagesc(x(1,:),y(:,1),stds);
axis xy;
title('Standard deviation','FontSize',14)
colorbar
