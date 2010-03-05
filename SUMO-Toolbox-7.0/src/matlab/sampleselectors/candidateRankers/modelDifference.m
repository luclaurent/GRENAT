classdef modelDifference < CandidateRanker

% modelDifference (SUMO)
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
%	modelDifference(config)
%
% Description:

	properties
		isc_opts;
	end
	
	methods (Access = public)
		
		function this = modelDifference(config)
			this = this@CandidateRanker(config);
			this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '2')));
		end
		
		
		function scores = scoreCandidates(this, points, state)

			% modelDifference (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:
			%   Calculates the difference between the last nLastModels models on the
			%   given points
			
			nLastModels = this.isc_opts; % 2; % Number of models to use 
			
			% number of outputs
			nOutputs = length(state.lastModels);
			
			% Construct differences
			scores = zeros(size(points,1), nOutputs);
			for l=1:nOutputs
				
				% get best models
				nModels = min(nLastModels, length(state.lastModels{l}));
				models = state.lastModels{l}(1:nModels);
				
				% evaluate best model values
				bestModelValues = evaluateInModelSpace(models{1}, points );
				
				% compare against previously best models
				for k=2:nModels
					modelValues = evaluateInModelSpace(models{k}, points );
					scores(:, l) = scores(:, l) + rootMeanSquareError( bestModelValues', modelValues')';
				end
				
				% if there are not enough models for this output - generate random scores
				if nModels < 2
					scores(:,l) = rand(size(points,1), 1);
				end
            end
            
			% That's all folks
		end
		
	end
	
end
