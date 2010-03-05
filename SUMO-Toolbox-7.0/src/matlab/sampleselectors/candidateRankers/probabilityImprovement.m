classdef probabilityImprovement < CandidateRanker

% probabilityImprovement (SUMO)
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
%	probabilityImprovement(varargin)
%
% Description:

	
	properties
		isc_opts;
		multiobjective;
		paretoFront = [];
		nValues;
	end
	
	methods (Access = public)
		
		function this = probabilityImprovement(varargin)
			this = this@CandidateRanker(varargin{:});
			
			if nargin == 1
				config = varargin{1};

				this.isc_opts = str2num(char(config.self.getOption('criterion_parameter', '[]')));
				this.multiobjective = config.self.getBooleanOption('multiobjective', false);
			elseif nargin == 4
				this.isc_opts = varargin{3};
				this.multiobjective = varargin{4};
			else
				error('Invalid number of parameters (1 or 4).');
			end
		end
		
		function [this] = initNewSamples(this, state)
			
			% multi objective
			if this.multiobjective
				
				% pareto front is empty, or new samples have arrived
				if isempty(this.paretoFront) || (this.nValues ~= size(state.samples,1))
					this.nValues = size(state.samples,1);
					[idx idxdom] = nonDominatedSort(state.values);
					this.paretoFront = sortrows(state.values(idxdom == 0,:));
				end
				
			end
		end

		function Pi = scoreCandidates(this, points, state)

			% probabilityImprovement (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			% Revision: $Rev: 6376 $
			%
			% Description:
			%     Calculates the probability of improvement for a point

			%% Multiobjective
			% Keane (2006), Hawe (2008)
			if this.multiobjective

				% TODO: may be one model with 2 outputs...
				if length( state.lastModels ) == 2
					model1 = state.lastModels{1}{1}; % output 1
					model2 = state.lastModels{2}{1}; % output 2

					y1 = model1.evaluateInModelSpace(points);
					mse1 = model1.evaluateMSEInModelSpace(points);
					y2 = model2.evaluateInModelSpace(points);
					mse2 = model2.evaluateMSEInModelSpace(points);

					y = [y1 y2];
					mse = [mse1 mse2];
				else
					model = state.lastModels{1}{1};
					y = model.evaluateInModelSpace(points);
					mse = model.evaluateMSEInModelSpace(points);

					assert( size( y, 2 ) == 2 ); % need 2 outputs
				end

				nrPareto = size( this.paretoFront, 1 ); % non-dominated, points are in increasing order
				nrPoints = size( points, 1 );

				zero = zeros(nrPoints, 1);
				one = ones(nrPoints, 1);

				%% Precalculate pdf's
				z1 = ( repmat(this.paretoFront(:,1)', nrPoints, 1) - repmat( y(:,1), 1, nrPareto) ) ./ repmat( mse(:,1), 1, nrPareto);
				phi1 = [zero normcdfWrapper(z1) one];

				z2 = ( repmat(this.paretoFront(:,2)', nrPoints, 1) - repmat( y(:,2), 1, nrPareto) ) ./ repmat( mse(:,2), 1, nrPareto);
				phi2 = [one normcdfWrapper(z2) zero];

				%% Calculate Pi_k
				% chance of improvement over k pareto points
				if isempty( this.isc_opts )
					k = 0; % default to 0
				else
					k = this.isc_opts;
				end
				Pi = 0;
				for j=k:nrPareto
					for i=1:(nrPareto-j+1)
						Pi = Pi + ((phi1(:,i+1)-phi1(:,i)) .* (phi2(:,j+i)-phi2(:,j+i+1)));
					end
				end

			%% singleobjective:
			else
				model = state.lastModels{1}{1};

				y = evaluateInModelSpace( model, points );
				s = evaluateMSEInModelSpace( model, points );
				values = getValues(model);
				fmin = min( values );
				if ~isempty( this.isc_opts );
					avg = mean(values);
					T = fmin + avg.*this.isc_opts; % lower
				else
					T = fmin;
				end

				z = (T - y) ./ s;
				Pi = normcdfWrapper(z);
			end
		end
		
	end
	
end
