classdef ModePursuingSampling < MergeCriterion

% ModePursuingSampling (SUMO)
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
%	ModePursuingSampling(varargin)
%
% Description:
%

	
	properties
		nrPoints = [];
		nrContours = [];
		logger = [];
	end
	
	methods (Access = public)
		
		
		function [this] = ModePursuingSampling(varargin)
			
			import java.util.logging.*
			this.logger = Logger.getLogger( 'Matlab.MPSSelector' );
			
			if nargin == 1
				config = varargin{1};
				
				dim_in = config.input.getInputDimension();
				this.nrPoints = config.self.getDoubleOption('nrPoints', dim_in.*10.^4);
				this.nrContours = config.self.getDoubleOption('nrContours', 10.^2);
			else
				dim_in = 2;
				this.nrContours = 10.^2;
			end
			
		end
		
		function [this, newsamples, priorities] = selectSamples(this, candidates, scores, state)
			
			[n k] = size(candidates); % #points and dim
			l = this.nrContours; % #contours

			fitness = scores - min(scores); % only requirement: criterion should be positive
			[fitness, index] = sort( fitness, 1, 'ascend' );
			candidates = candidates(index,:); % sort
			
			%% Contourization
			u = n/l; % partition size
			E = cell(l, 1);
			Efitness = zeros(l,1);
			Eindex = [1:u:n;u:u:n+u-1]; % indexer
			for i=1:l
				E{i} = struct( 'samples', candidates( Eindex(1,i):Eindex(2,i), 1:k), ...
							   'fitness', fitness( Eindex(1,i):Eindex(2,i) ) );
				Efitness(i) = sum( fitness( Eindex(1,i):Eindex(2,i) ) );
			end

			totalfitness = sum(fitness);
			a = Efitness ./ (u.*totalfitness);
			pe = a .* u;

			%% Sampling
			m = state.numNewSamples; % #samples to draw

			% draw m samples from 1:l with probabilities pe/sum(pe) = pe (with
			% replacement)
			draws = randsample(l,m,true,pe);

			[draws, dummy, index] = unique(draws);
			countdraws = accumarray(index(:), 1);

			% return m candidates
			newsamples = []; %zeros(m,k);
			for i=1:size(draws,1)
				% draw countdraws(i) samples from 1:u (without replacement)
				index = randsample(u, countdraws(i), false );
				newsamples = [newsamples ; E{draws(i)}.samples(index,:) ];
			end

			% return their priorities
            %priorities = scores(ranking,:);
			priorities = ones(m,1); % TODO
			
		end
		
		
		
		
		
	end

	
end
