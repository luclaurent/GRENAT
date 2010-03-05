function [this, newsamples, priorities] = selectSamples(this, state)

% selectSamples (SUMO)
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
%	[this, newsamples, priorities] = selectSamples(this, state)
%
% Description:
%	Optimises the infill sampling criterion
%	Filter the samples and return them

%% Apply constraints
% check for input constraints
c = Singleton('ConstraintManager');
if c.hasConstraints()
	this.funcOptimizer = setInputConstraints( this.funcOptimizer, c.getConstraints());
end

%% Get optimizer
inDim = size(state.samples,2);
outDim = size(state.values,2);
this.funcOptimizer = this.funcOptimizer.setDimensions(inDim,outDim);

% if there is a candidate generator, use it to set the initial population
if ~isempty(this.candidateGenerator)
	
	% generate the candidates
	[this.candidateGenerator, state, initialPopulation] = this.candidateGenerator.generateCandidates(state);
	
	% check if the number does not exceed the allowed number
	if size(initialPopulation,1) > this.funcOptimizer.getPopulationSize()
		this.logger.warning(sprintf('Optimizer %s only allows %d samples for the initial population, while candidate generator %s produced %d. Ignoring initial population.', class(s.funcOptimizer), s.funcOptimizer.getPopulationSize(), class(s.candidateGenerator), size(initialPopulation,1)));
	else
		this.funcOptimizer = this.funcOptimizer.setInitialPopulation(initialPopulation);
	end
	
end

% give the state to the optimizer - might contain useful info such as # samples
this.funcOptimizer = this.funcOptimizer.setState(state);

% the new samples
newsamples = zeros(0,inDim);

%% as long as no samples are found, move on to the next criterion
for k = 1 : length(this.candidateRankers)
	
	if k > 1
		this.logger.warning(sprintf('Criterion %s could not find any samples, now trying next criterion %s', this.candidateRankers{k-1}.getType(), this.candidateRankers{k}.getType()));
	end
	
	% init the sample ranker
	this.candidateRankers{k} = this.candidateRankers{k}.initNewSamples(state);
	
	% get the sample ranker
	candidateRanker = this.candidateRankers{k};
	
	% turn into a criterion
	criterion = @(x)(-candidateRanker.score(x, state));
	
	% optimize
	[this.funcOptimizer, foundsamples, foundvalues] = this.funcOptimizer.optimize(criterion);
	
	% remove duplicates
	dups = buildDistanceMatrix( foundsamples, [state.samples ; state.samplesFailed], 1 );
	index = find(all(dups > eps, 2));
	newsamples = foundsamples(index,:);
	newvalues = foundvalues(index,:);
    
    % we found samples - we're done
    if ~isempty(newsamples)
        break;
    end
end


%% no criteria managed to find any samples - generate random samples
if isempty(newsamples) && this.randomSamples
	newsamples = -1 + 2.*rand(state.numNewSamples,size(state.samples,2));
	newvalues = (1:state.numNewSamples)';

	% Solely needed for debug plots
	foundsamples = newsamples;
	foundvalues = newvalues;

	this.logger.warning( 'No unique samples found, falling back to random samples' );
end


%% no priorities here
priorities = zeros(size(newsamples,1), 1);


%% try to uphold the wishes of the modeller, return best ones
nNew = min( state.numNewSamples, size( newsamples, 1 ) );

[dummy, index] = sort(newvalues, 1);
newsamples = newsamples(index(1:nNew), :);
priorities = priorities(index(1:nNew), :);

%% debug, plots
if this.debug

	this.candidateRankers{k}.plotCriterion( state );
	%this.plotCriterion( state, foundsamples );
	
	if size( state.samples, 2) == 1 
		% candidate samples
		plot(foundsamples, foundvalues, '*', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');

		% selected samples
		plot(newsamples, newvalues, '*', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
	elseif size( state.samples, 2) == 2

		% candidate samples
		plot(foundsamples(:,1), foundsamples(:,2),'ko','Markerfacecolor','r');

		% selected samples
		plot(newsamples(:,1), newsamples(:,2), '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
		
		% optimums
			%mi = [-pi, 12.275;pi, 2.275;9.42478, 2.475] + repmat([-2.5,-7.5],3,1); % BRANIN
			%mi = mi ./ 7.5;

			%mi = ([1.2279713, 4.2453733]-5)/5; % conG8

			%mi = [0,-1]/2; % Goldstein Price
			%mi = [-0.0898,0.7127;0.0898,-0.7127] ./ repmat([2,1],2,1); % Six Hump Camelback
			%mi = ([0.2316,0.1216;0.2017,0.8332] - 0.5) .* 2.0; % superEGO_Test2
			%plot( mi(:,1), mi(:,2), 'x', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');

			%{
			temp = 1./sqrt(2);
			mop = [-temp -temp ; temp temp];
			mop = mop ./ 2;
			plot( mop(:,1), mop(:,2), 'k-', 'LineWidth',2 );
			%}


			% VLMOP2
			%{
			temp = 1./sqrt(2);
			mop = [-temp -temp ; temp temp];
			mop = mop ./ 2;
			plot( mop(:,1), mop(:,2), 'k-', 'LineWidth',2 );
			%}


			% OKA1
			%x1 = linspace( 0, 2*pi, 20 );
			%x2 = 3.*cos(x1) + 3;
			%x1 = (x1 - 4.5874) / 3.0345;
			%plot( x1, x2, 'k-', 'LineWidth',2 );
			% LB: [1.5529 -1.6262]
			% UB: [7.6220 5.7956]
			% transl: 4.5874    2.0847
			% scale: 3.0345    3.7109
			
			% constraints
			%for i=1:length(c.obj.constraints)
			%	cdata = reshape( evaluate( c.obj.constraints{i}, [x1(:) x2(:)] ), size(x1) );
			%	contour(x,x,cdata,[0,0], 'w--');
			%end
	end
			
    hold off
end
