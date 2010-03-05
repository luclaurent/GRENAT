classdef SampleManager

% SampleManager (SUMO)
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
% Revision: $Rev: 6396 $
%
% Signature:
%	SampleManager(config)
%
% Description:
%	This class processes new samples and stores them, so that they can
%	later be requested in both simulator and toolbox space.
%	This class handles all the post-processing needed to
%	  a/ filter the correct outputs
%	  b/ convert real/imaginary parts of a complex number
%	     to either the modulus, the phase, a complex number, or the real/imaginary parts.

  properties(Access = private)
    logger = java.util.logging.Logger.getLogger('Matlab.SampleManager');
    complexHandling;
    outputSelect;
    dimension;
    simulatorInputDimension;
    simulatorOutputDimension;
    outputs;
    inputs;
    outputModifiers;
    ignoreNaN;
    ignoreInf;
    translate;
    scale;
    constantInputMask;
    autoSampledDimensions;
    outputDirectory;
    triangulationObj;
    samples;
    samplesUnfiltered;
    values;
    valuesUnfiltered;
    failedSamples;
	failedSamplesUnfiltered;
    failedValues;
	failedValuesUnfiltered;
    failedReasons;
  end

  methods(Access = public)
    
    function s = SampleManager(config)

      import java.util.logging.*
      import ibbt.sumo.profiler.*;
      
      % get type of each output, so that we can convert them properly later
      complexHandling = {};
      outputs = config.output.getOutputDescriptions();
      outputModifiers = {};
      ignoreNaN = [];
      ignoreInf = [];

      for i = 1:config.output.getOutputDimension()
	      
	      % get complex handling setting for each output
	      complexHandling = [complexHandling char(outputs(i).getType())];
	      
	      % get modifiers and instantiate them
	      modifiers = outputs(i).getModifiers();
	      objects = cell(1,modifiers.size());
	      for j = 0:modifiers.size()-1
		      modifier = modifiers.get(j);
		      modifier = instantiate(modifier, config);
		      if ~isa(modifier, 'DataModifier')
			      msg = 'Invalid DataModifier specified!';
			      s.logger.severe(msg);
			      error(msg);
		      end
		      objects{j+1} = modifier;
	      end
	      
	      % add to list
	      outputModifiers = [outputModifiers {objects}];
	      
	      % add ignore configs
	      ignoreNaN = [ignoreNaN outputs(i).ignoreNaN()];
	      ignoreInf = [ignoreInf outputs(i).ignoreInf()];
      end

      % get inputs
      inputs = config.input.getInputDescriptions();

      % get data
      simulatorInputDimension = config.input.getSimulatorInputDimension();

      % Initialise the tranformation vectors & auto sampling filter
      transl = zeros(1,config.input.getInputDimension());
      scale = zeros(1,config.input.getInputDimension());
      j=1;
      autoSampledDimensions = false(1,0);

      % walk over all normal inputs
      for i = 1:length(inputs)
	      input = inputs(i);
	      index = input.getInputSelect() + 1;
	      
	      % define translation/scale matrices
	      min = input.getMinimum();
	      max = input.getMaximum();
	      transl(j) = (max+min)/2.0;
	      scale(j) = (max-min)/2.0;
	      j=j+1;
	      
	      % add auto-sampled dimensions
	      autoSampledDimensions = [autoSampledDimensions input.isSampledAutomatically()];
      end

      % mask which represents a sample with the constant values already filled in
      constantInputMask = zeros(simulatorInputDimension, 1);
      constantInputs = config.input.getConstantInputDescriptions();
      for i = 1:length(constantInputs)
	      input = constantInputs(i);
	      index = input.getInputSelect() + 1;
          
          if isnan( input.getValue() )
            min = constantInputs(i).getMinimum();
            max = constantInputs(i).getMaximum();
            constantInputMask(index) = (min+max) ./ 2; % middle of domain
          else
            constantInputMask(index) = input.getValue();
          end
	  end


      s.complexHandling = complexHandling;
      s.outputSelect = str2num(char(config.output.getOutputSelectString())) + 1;
      s.dimension = config.input.getInputDimension();
      s.simulatorInputDimension = simulatorInputDimension;
      s.simulatorOutputDimension = config.output.getSimulatorOutputDimension();
      s.outputs = outputs;
      s.inputs = inputs;
      s.outputModifiers = outputModifiers;
      s.ignoreNaN = ignoreNaN;
      s.ignoreInf = ignoreInf;
      s.translate = transl;
      s.scale = scale;
      s.constantInputMask = constantInputMask;
      s.autoSampledDimensions = autoSampledDimensions;
      s.outputDirectory = char(config.context.getOutputDirectory());
      s.samples = zeros(0, config.input.getInputDimension());
      s.samplesUnfiltered = zeros(0, config.input.getSimulatorInputDimension());
      s.values = zeros(0, config.output.getOutputDimension());
      s.valuesUnfiltered = zeros(0, config.output.getSimulatorOutputDimension());
      s.failedSamples = zeros(0, config.input.getSimulatorInputDimension());
	  s.failedSamplesUnfiltered = zeros(0, config.input.getSimulatorInputDimension());
      s.failedValues = zeros(0, config.output.getSimulatorOutputDimension());
	  s.failedValuesUnfiltered = zeros(0, config.output.getSimulatorOutputDimension());
      s.failedReasons = cell(0,1);
      s.triangulationObj = Triangulation([]);
	  
      % Display which outputs we model
      str = ['Outputs to filter: ' char(config.output.getOutputNamesAsString(' '))];
      s.logger.fine(str);
    end

    function out = getNrSamples(this)
      out = size(this.samples, 1);
    end

    function [t] = getTriangulationObj(s)
      t = s.triangulationObj;
    end

    [newSamples] = addAutoSampledDimensions(s, samples);
    [s, numAdded, numDuplicate, numInvalid, numOutOfRange] = add(s, newSamplesUnfiltered, newValuesUnfiltered, newSampleIds);
    [samples, values] = getInModelSpace(s);
    [samplesUnfiltered, valuesUnfiltered] = getInSimulatorSpace(s);
    [transf] = getTransformationValues(s);
    [newA, newB] = linearEquationToModelSpace(this, A, B);
    [s, samples] = prepareForEvaluation(s, filteredSamples, priorities);
    [] = saveToDisk(s, outputDirectory);
  end

  methods(Access = private)
    [fixedInputValues] = filterInputs(s, inputValues);
    [s, newValues] = filterOutputs(s, unfilteredValues);
    [badIndices numDups] = removeDuplicateSamples(newSamples, prevSamples);
    [badIndices, numInvalid] = removeInvalidValues(s, newSamples, newValues);
    [badIndices, numOutOfRange] = removeOutOfRangeSamples(s, newSamples, newValues);
    [s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues] = removeSamplesByIndex(s, newSamplesUnfiltered, newValuesUnfiltered, newSamples, newValues, index, reason);
    [] = saveDataToDisk(s, fileName, header, samples, values, reasons);
    [s,points] = toSamplePoints(s, p, priorities);
    [sample] = unfilterInputs(s, sample);
  end

end
