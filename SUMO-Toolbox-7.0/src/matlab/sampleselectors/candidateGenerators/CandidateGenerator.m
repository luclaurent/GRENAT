classdef CandidateGenerator

% CandidateGenerator (SUMO)
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
%	CandidateGenerator(config)
%
% Description:
%	An abstract class that provides an easy and convenient interface for
%	generating candidates, either by subclassing from this one, or by
%	just calling it directly, through a function.

properties
	executeFunctionHandle = false;
	functionHandle;
	inDim;
end

methods (Access = public)
	
	function [this, state, newSamples] = generateCandidates(this, state)
		%	This function will either call the function handle, or call a
		%	subclass function.
		
		if this.executeFunctionHandle
			[state, newSamples] = feval(this.functionHandle, state);
		else
			newSamples = zeros(0, this.inDim);
		end
	end
	
	function [this] = CandidateGenerator(config)
		%	This constructor will look for an option specifying a generator
		%	function to call. If such an option is found, the samples are
		%	generated from this function. Otherwise it is left to the
		%	subclass.
		
		% subclassed - we don't need the config in that case
		if ~exist('config', 'var')
			return;
		end
		
		% only execute the function handle of the type is not a class
		this.functionHandle = char(config.self.getAttrValue('type', ''));
		this.executeFunctionHandle = ~isempty(this.functionHandle) && isempty(meta.class.fromName(this.functionHandle));
		this.inDim = config.input.getInputDimension();
	end
	
	
	function [inDim] = getInputDimension(this)
		inDim = this.inDim;
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
