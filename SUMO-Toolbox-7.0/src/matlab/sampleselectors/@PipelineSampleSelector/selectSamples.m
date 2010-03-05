function [s, newsamples, priorities] = selectSamples(s, state)

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
% Revision: $Rev: 6376 $
%
% Signature:
%	[s, newsamples, priorities] = selectSamples(s, state)
%
% Description:
%	Call selectSamples on each subobject and glue them together

s.logger.fine('Starting combined sample selection...');


% generate initial set of candidates
[s.candidateGenerator, state, candidates] = s.candidateGenerator.generateCandidates(state);
s.logger.fine(sprintf('Generated %d candidate samples using %s', size(candidates,1), class(s.candidateGenerator)));

% initialize score set
scores = zeros(size(candidates,1), length(s.candidateRankers));

% now walk over all the scorers, and add their rankings
for k=1:length(s.candidateRankers)
	
	% call init function
	s.candidateRankers{k} = s.candidateRankers{k}.initNewSamples(state);
	
	% rank the candidates
	[ranking] = s.candidateRankers{k}.score(candidates, state);
	scores(:,k) = ranking;
	s.logger.fine(sprintf('Finished ranking candidates with %s', class(s.candidateRankers{k})));
end

% now select samples out of the candidate-set based on some criterion
[s.mergeCriterion, newsamples, priorities] = s.mergeCriterion.selectSamples(candidates, scores, state);

% debug plot of criterion (1D: plot, 2D: contourf)
if s.debug
	s.candidateRankers{1}.plotCriterion( state );
	
	% hack to plot delaunay overlay
	if isfield( state, 'candidatesToTriangles' )
		state.triangulation.plotTriangulation();
	end

	if size( state.samples, 2) == 1 
		% candidate samples
		%plot(candidates, scores(:,k), '*', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
		
		% new samples
		plot(newsamples, priorities, '*', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
	elseif size( state.samples, 2) == 2
		% candidate samples
		%plot(candidates(:,1), candidates(:,2),'ko','Markerfacecolor','k');
		
		% new samples
		plot(newsamples(:,1), newsamples(:,2),'g*','Markerfacecolor','g');
	end
end
