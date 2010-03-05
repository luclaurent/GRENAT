classdef WeightedAverage < MergeCriterion

% WeightedAverage (SUMO)
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
%	WeightedAverage(arg)
%
% Description:
%	WeightedAverage performs a weighted averaged merging of the
%	different scores.

	
	properties
		weights;
	end
	
	
	methods (Access = public)
		
		
		function [this] = WeightedAverage(arg)
			if isnumeric(arg)
				this.weights = arg;
			else
				config = arg;
				this.weights = str2num(config.self.getAttrValue('weights', '[]'));
			end
		end
		
		function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)
			
		
			% if weights is empty, give each score the same weight
			if isempty(this.weights)
				this.weights = ones(1, size(scores,2));
			end
			
			% make sure it's a column vector
			if size(this.weights,1) ~= 1
				this.weights = this.weights';
            end
            
			% determine the weighted average score
			scores = sum(bsxfun(@times, scores, this.weights),2) ./ size(scores,2);
            
            % get ranking from scores
            [dummy, ranking] = sort(scores, 1, 'descend');
			
			% only get the n best ones
			nNew = min( state.numNewSamples, size( candidates, 1 ) );
			ranking = ranking(1:nNew);
			
			% return the n best candidates
			newSamples = candidates(ranking,:);
            
            % return their priorities based on the weighted average score
            priorities = scores(ranking,:);
			
		end
	end
end
