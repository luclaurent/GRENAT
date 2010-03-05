classdef CandidateRanker

% CandidateRanker (SUMO)
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
%	CandidateRanker(varargin)
%
% Description:
%	An interface that allows the object to score a set of candidates
%	according to its own system. This is used in the
%	PipelineSampleSelector to score a set of externally generated
%	candidate samples according to some criterion.
%	Note: when a candidate ranker gives a HIGHER score to a candidate, the
%	sample selector will prefer this candidate above one with a LOWER
%	score.

properties
	inDim;
	scalingFunction;
    sortOrder = 'max';
end

methods (Access = public, Abstract = true)
    [scores] = scoreCandidates(this, candidates, state);
end

methods (Access = public)
	
	function [this] = initNewSamples(this, state)
		% does nothing by default
	end
	
	function [this] = CandidateRanker(varargin)
		% Description:
		%	This constructor will look for an option specifying a generator
		%	function to call. If such an option is found, the samples are
		%	generated from this function. Otherwise it is left to the
		%	subclass.
		
		% nothing specified - right now, an invalid object
		if nargin == 0
			return;
		
		% subclassed - we don't need the config in that case
		elseif nargin == 1
			config = varargin{1};
			
			this.inDim = config.input.getInputDimension();
		
			% get the scaling function
			this.scalingFunction = char(config.self.getAttrValue('scaling', 'onetozero'));
		elseif nargin >= 2 % assume individual parameters
			this.inDim = varargin{1};
			this.scalingFunction = varargin{2};
			% rest of parameters is for inherited classes
		end
		
		this.scalingFunction = constructScalingFunction(this.scalingFunction);
	end
	
	function plotCriterion(this, state)
		persistent iscPlot;

		if isempty(iscPlot)
			iscPlot = figure;		
		else
			iscPlot = figure( iscPlot );
		end

		if size( state.samples, 2) == 1 
			x = linspace(-1,1,100 )';
			y = this.score( x, state );
			plot(x,y);
			hold on

			% samples
			plot(state.samples, this.score( state.samples, state ), 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');

		elseif size( state.samples, 2) == 2
			x = linspace(-1,1,100)';
			[x1, x2] = meshgrid( x, x );
			isc = this.score( [x1(:) x2(:)], state );
			isc = reshape(isc, size(x1));
			[C, f] = contourf( x,x,isc);
			clabel( C, f );
			%set(text_handle,'BackgroundColor',[1 1 .6], 'Edgecolor',[.7 .7
			%.7])
			colorbar
			hold on

			% samples
			plot(state.samples(:,1), state.samples(:,2),'ko','Markerfacecolor','c');
		end
	end % end plotCriterion function
end


methods (Access = public, Sealed = true)
	
    % This function will call the subclass score function, and then
    % transfom the raw scores through a number of transformations
    % (inversion, scaling).
	function [scores] = score(this, candidates, state)
		
        % get the raw scores
		[scores] = this.scoreCandidates(candidates, state);
        
        % invert the scores if the sort order is not 'max'
        % this is done because users of CandidateRanker assume that samples
        % with a HIGH score (or error) are the ones that are to be above
        % the ones with a LOW score.
        if ~strcmp(this.sortOrder, 'max')
            scores = -scores;
        end
		
		% scale the scores
		scores = this.scalingFunction(scores);
    end
    
    

    function [this] = setOrder(this, order)
        this.sortOrder = order;
    end
    
    
    function [typeName] = getType(this)
        typeName = class(this);
	end
	
	function [this] = instantiate(this, inDim, varargin)
		% Description:
		%	This function sets some members of a subclass through dynamic
		%	indexation.
		nargin
		for i = 1 : 2 : nargin - 2
			this.(varargin{i}) = varargin{i+1};
		end
		this.inDim = inDim;
		this.scalingFunction = constructScalingFunction('none');
	end
	
end
	
end
