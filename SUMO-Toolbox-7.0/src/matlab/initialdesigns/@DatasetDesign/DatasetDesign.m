classdef DatasetDesign < InitialDesign

% DatasetDesign (SUMO)
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
%	DatasetDesign(config)
%
% Description:
%	Read an initial design from a dataset

  properties
    filename;
    hasOutputs;
	simulatorInputDimension;
    simulatorOutputDimension;
  end
  
  methods
	  
    function this = DatasetDesign(config)
      % construct the base class
      this = this@InitialDesign(config);

      this.filename = char(config.self.getOption('filename',''));

      if(isempty(this.filename))
	error('No filename specified!');
      end

      this.filename = char(config.context.findFileInPath(this.filename));
      this.hasOutputs = config.self.getBooleanOption('hasOutputs', true);
	  this.simulatorInputDimension = config.input.getSimulatorInputDimension();
      this.simulatorOutputDimension = config.output.getSimulatorOutputDimension();
    end

    % load raw data from disk, the SampleManager will take care of dimension checking
    % and possible input/output filtering
    function [initialsamples, evaluatedsamples] = generate(this)
		
		import ibbt.sumo.sampleevaluators.*;
		import java.util.logging.*
		logger = Logger.getLogger( 'Matlab.DatasetDesign' );

		% load & filter samples
		samples = load(this.filename);

		% outputs in file - no need to evaluate
		if this.hasOutputs
			initialsamples = [];
			evaluatedsamples = samples;

			if size(evaluatedsamples,2) ~= this.simulatorInputDimension + this.simulatorOutputDimension
				msg = sprintf('Dataset does not have %d values (%d inputs and %d outputs) for each sample', this.simulatorInputDimension+this.simulatorOutputDimension, this.simulatorInputDimension, this.simulatorOutputDimension);
				logger.severe(msg);
				error(msg);
			end

		% no outputs - evaluate them later
		else
			initialsamples = samples; 
			evaluatedsamples = [];	

			if size(initialsamples,2) ~= this.simulatorInputDimension
				msg = sprintf('Dataset does not have %d values (%d inputs) for each sample', this.simulatorInputDimension, this.simulatorInputDimension);
				logger.severe(msg);
				error(msg);
			end
		end

    end

  end
end
