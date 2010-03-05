function seed = genNewOptimizationSeed(searchHistory, scores, reliability, numNew, LB, UB )

% genNewOptimizationSeed (SUMO)
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
%	seed = genNewOptimizationSeed(searchHistory, scores, reliability, numNew, LB, UB )
%
% Description:
%	Given a history of previous model parameter optimization runs, a set of scores (lower is better, >= 0)
%	where each score corresponds to each point in the history, and a measure of how reliable each run in
%	the history is (in [0 1]), predict the n most interesting starting points for a new optimization.
%	LB, UB denote the lower and uppberbounds of the search space.

% dimension of the search space
dim = size(searchHistory,2);

% re-arrange scores from lower is better to higher is better ensuring that the scores stay positive
% this means that the perfect score changes from 0 to maxScore+1
scores = (-scores) + max(scores) + 1;
minSc = min(scores);
maxSc = max(scores);

% do an approximate voronoi tesselation of the search space that has been covered so far
[approxVoronoi largestVoronoiPerc] = approximateVoronoi( searchHistory, LB, UB );

% scale the size of each approximate voronoi cell (between 0 and 1) to the same range as the scores
density = scaleColumns(approxVoronoi.areas,minSc,maxSc);

% alpha determines the relative importance of exploration vs exploitation
% 0.5 : equally important ; > 0.5 : scores are more important ; < 0.5 : density is more important
alpha = 0.65;

% combine the different scores
if(isempty(reliability))
	% every point in the searchHistory is equally important, take into account coverage and scores
	combinedScore = (1 - alpha)*density + alpha*scores;
else
	% not every point is equally reliable, reduce the score by multiplying it with its reliability
	% => since the reliability is in [0 1], very unreliable points have their score set to to almost zero
	%	=> degrades to a density based coverage only
	%	=> the higher the reliability, the more the scores are taken into account
	combinedScore = ( (1 - alpha) * density ) + ( alpha * (scores .* reliability) );
end

% For debugging
%  figure
%  o = plotScatteredData();
%  o.contour = 1;
%  plotScatteredData([searchHistory density],o);
%  hold on
%  voronoi(searchHistory(:,1),searchHistory(:,2));
%  hold off
%  colorbar
%  set(gca,'XLim',[-1 1]);
%  set(gca,'YLim',[-1 1]);
%  title('Density')
%  
%  figure
%  plotScatteredData([searchHistory scores],o);
%  colorbar
%  set(gca,'XLim',[-1 1]);
%  set(gca,'YLim',[-1 1]);
%  title('Score')
%  
%  figure
%  plotScatteredData([searchHistory combinedScore],o);
%  colorbar
%  set(gca,'XLim',[-1 1]);
%  set(gca,'YLim',[-1 1]);
%  title('combined')


% sort the combined scores, higher score => more interesting location
[Y I] = sort(combinedScore,1,'descend');

maxNew = min(length(I),numNew);

% Get the points that scored the best
newIndices = I(1:maxNew);

seed = [];
for i=1:length(newIndices)
	% get all the monte carlo points inside the i'th voronoi cell
	v = approxVoronoi.closestPoints{newIndices(i)};

	if(length(v) < 1)
		% choose a random starting point
		p = zeros(1,dim);
		for i=1:dim
            p(1,i) = boundedRand(LB(i),UB(i));
		end
	elseif(size(v,1) == 1)
		p = v(1,:);
	else	
		if(size(searchHistory,1) <= 1000)
			% as a new candidate select the monte carlo point that is the furthest away from any other point
			% in the search history
			dist = buildDistanceMatrix(v,searchHistory,0);
			
			[y J] = min(dist,[],2);
			[y K] = max(y);
			
			p = v(K(1),:);
		else
			% select a candidate randomly to save time
			perm = randperm(size(v,1));
			p = v(perm(1),:);
		end
	end
	
	seed = [seed ; p];
	searchHistory = [searchHistory ; p];
end

% If the number of requested points is bigger than the number of points we already have
% return the rest randomly
% TODO: a monte carlo approach could be used here as well for a more efficient, density based distribution
numExtra = max(numNew - newIndices,0);
if(numExtra > 0)
	extra = zeros(numExtra,dim);
	for i=1:dim
		extra(:,i) = boundedRand(LB(i),UB(i));
	end
	seed = [seed ; extra];
end

%  hold on
%  plot(seed(:,1),seed(:,2),'k*','MarkerSize',15);
%  hold off
