classdef ConstraintManager < handle

% ConstraintManager (SUMO)
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
%	ConstraintManager(config)
%
% Description:
%

   properties
	   constraints;
	   autoSampledInputs = [];
	   inDim;
   end

   methods (Access=public)
	   
	   % constructor
	   function this = ConstraintManager(config)
			import java.util.logging.*
			logger = Logger.getLogger('Matlab.ConstraintManager');
		   
            % check inputs for auto-sampling - might be used later before
            % passing to the sample manager
            inputs = config.input.getInputDescriptions();
			this.inDim = length(inputs);
            for i = 1:this.inDim
                if inputs(i).isSampledAutomatically()
                    this.autoSampledInputs = [this.autoSampledInputs i];
                end
            end
			
			
		   
			% input constraint handling
			% read xml-data from config file
			sim = config.context.getSimulatorConfig();
			subs = sim.getInputConstraints();

			% instantiate all subobjects as defined in the config file
			c=cell(1,subs.size());
			for i=0:subs.size()-1
				c{i+1}=instantiate(subs.get(i), config);
			end

			% output
			if length( c ) < 1
				msg = 'No constraints specified.';
				logger.info(msg);
			else
				msg = sprintf( '%i constraints specified and parsed', subs.size() );
				logger.info( msg );
			end
			
			% set constraints
			this.constraints = c;
	   
	   end
	   
	   
	   % satisfy all constraints for one sample
	   function success = satisfySample(this, sample)
		   success = ~isempty(satisfySamples(this, sample));
	   end
	   
	   % satisfy all constraints for a set of samples
	   function indices = satisfySamples(this, samples)
		   
		   % see if the samples have their auto sampled inputs missing
		   % in this case, the constraint is being called from within a
		   % sample selector - add zero-columns for every auto sampled
		   % input
		   if size(samples,2) < this.inDim
			  for i = this.autoSampledInputs
				  samples(:, i:end) = samples(:, (i+1):(end+1));
				  samples(:, i) = zeros(size(samples,1), 1);
			  end
		   end
		   
			if isempty(this.constraints)
				indices = (1:size(samples,1))';	
			else
				constraintValues = zeros( size(samples,1), length(this.constraints) );
				for i=1:length(this.constraints)
					constraintValues(:,i) = evaluate( this.constraints{i}, samples );
				end
				constraintValues = max(constraintValues, [], 2);
				indices = find(constraintValues <= 0);
			end
		   
	   end
	   
	   
	   % return the maximum violation of the constraints for one sample
	   function out = returnHighestViolation(this, x)
			y = zeros( size(x,1), length(this.constraints) );
			for i=1:length(this.constraints)
				y(:,i) = evaluate( this.constraints{i}, x );
			end

			out = max(y,[],2);
	   end
	   
	   
	   % get the constraints
	   function c = getConstraints(this)
		   c = this.constraints;
	   end
	   
	   function yes = hasConstraints(this)
		   yes = ~isempty(this.constraints);
	   end
   end
end 
