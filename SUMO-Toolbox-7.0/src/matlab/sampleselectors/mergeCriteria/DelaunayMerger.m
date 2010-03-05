classdef DelaunayMerger < MergeCriterion

% DelaunayMerger (SUMO)
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
%	DelaunayMerger(varargin)
%
% Description:
%	WeightedAverage performs a weighted averaged merging of the
%	different scores.

	
	properties
		strategy;
		weights;
	end
	
	
	methods (Access = public)
		
		
		function [this] = DelaunayMerger(varargin)
			
			% call superclass
			%this = this@MergeCriterion(varargin{:});
			
			if nargin == 1
				config = varargin{1};
				this.strategy = char(config.self.getAttrValue('strategy', 'all'));
				this.weights = str2num(config.self.getAttrValue('weights', '[]'));
			else
				this.strategy = varargin{1};
				this.weights = varargin{2};
			end
		end
		
		function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)
			
            % if the mapping exists already, it's easy
			if isfield(state, 'candidatesToTriangles')
				candidatesToTriangles = state.candidatesToTriangles;
			% otherwise, figure it out yourself
			else
				[T centers volumes] = state.triangulation.getTriangulation();
				candidatesToTriangles = tsearchn(state.samples, T, candidates);
			end
			
			dim_in = size(candidates,2);
			nrTriangles = max(candidatesToTriangles);
			
			newSamples = zeros( nrTriangles, dim_in );
			newScores  = zeros( nrTriangles, size(scores,2) );
			for i=1:nrTriangles
				% Get score at centers of simplices
				idx = find( candidatesToTriangles == i );
				%volumes(candidatesToTriangles)

				if strcmp( this.strategy, 'middle' )
					% best point is always the center point
					% advantage: samples are more spread out (useful for GP based models)
					newScores(i,:) = mean(scores(idx,:),1);
					newSamples(i,:) = candidates(idx(1,:), :);
				else %if strcmp( this.strategy, 'best' )
					% the best point in the simplex is the one with the greatest score
					[newScores(i,:) idxTriangle] = max( scores(idx,:), [], 1 );
					newSamples(i,:) = candidates(idx(idxTriangle(1),:), :);
				end

			end
		
			% determine the weighted average score
			newScores = sum(bsxfun(@times, newScores, this.weights),2) ./ size(newScores,2);
            
            % get ranking from scores
            [dummy, ranking] = sort(newScores, 1, 'descend');
			
			% only get the n best ones
			nNew = min( state.numNewSamples, size( newSamples, 1 ) );
			ranking = ranking( 1:nNew);
			
			% return the n best candidates
			newSamples = newSamples(ranking,:);
            
            % return their priorities based on the weighted average score
            priorities = newScores(ranking,:);
		end
		
	end

	
end
