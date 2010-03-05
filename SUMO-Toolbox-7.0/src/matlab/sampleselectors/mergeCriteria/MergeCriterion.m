classdef MergeCriterion

% MergeCriterion (SUMO)
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
%	MergeCriterion(config)
%
% Description:
%	Implement this interface if you want to be able to select a set of
%	samples that have to be evaluated from a set of candidates, based on
%	one or more rankings provided by other objects. This is used in
%	PipelineSampleSelector to merge the rankings provided by the
%	different CandidateRankers's into one definitive set of samples.

properties
	executeFunctionHandle = false;
	functionHandle;
	inDim;
end

methods (Access = public)
	
	function [this, newSamples, priorities] = selectSamples(this, candidates, scores, state)
		%	This function will either call the function handle, or call a
		%	subclass function.
		
		if this.executeFunctionHandle
			[newSamples, priorities] = feval(this.functionHandle, candidates, scores, state);
		else
			newSamples = candidates;
            priorities = zeros(size(candidates,1), 1);
		end
	end
	
	function [this] = MergeCriterion(config)
		%	This constructor will look for an option specifying a generator
		%	function to call. If such an option is found, the samples are
		%	generated from this function. Otherwise it is left to the
		%	subclass.
		
		% subclassed - we don't need the config in that case
		if ~exist('config', 'var')
			return;
		end
		
		this.functionHandle = char(config.getAttrValue('type', ''));
		this.executeFunctionHandle = ~isempty(this.functionHandle) && isempty(meta.class.fromName(this.functionHandle));
		this.inDim = config.input.getInputDimension();
    end
    
    function [typeName] = getType(this)
        if this.executeFunctionHandle
            typeName = this.functionHandle;
        else
            typeName = class(this);
        end
    end
	
end

end
