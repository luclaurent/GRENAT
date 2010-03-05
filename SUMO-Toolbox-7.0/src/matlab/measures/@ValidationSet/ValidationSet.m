classdef ValidationSet < Measure

% ValidationSet (SUMO)
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
%	ValidationSet(config)
%
% Description:
%	This measure uses a set of validation samples, not used for construction of
%	the model, to estimate the accuracy of the model. There are two sources
%	for this set of validation samples:
%
%	1. They are taken as a subset of the list of evaluated samples. If this
%	option is chosen, the samples are chosen in such a way that the entire
%	domain is covered as optimally as possible (using a distance metric).
%	2. They are loaded from a file. This file is provided in the same way
%	as a dataset file for the sample evaluator is.
%
%	This measure is very useful for validation purposes.

    
    
    properties(Access = private)
        logger;
        percentUsed;
        validationSamples;
        validationValues;
        set;
        randomThreshold;
    end
    
    methods(Access = public)
        
        function m = ValidationSet(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            m = m@Measure(config);
            
            m.logger = Logger.getLogger('Matlab.measure.ValidationSet');
            
            % Get options
            %percent of the total available samples used for validationing
            percentUsed = config.self.getIntOption('percentUsed', 20);
            dataset = config.self.getOption('type', 'distance');
            
            if ~strcmp(dataset,'distance') && ~strcmp(dataset,'random') && ~strcmp(dataset, 'file')
                msg = 'Type must be one of "distance", "random", or "file".';
                m.logger.severe(msg);
                error(msg);
            end
            
            % get random threshold
            randomThreshold = config.self.getIntOption('randomThreshold', 2000);
            
            % validation data set, initialized empty
            validationSamples = [];
            validationValues = [];
            
            % we want to read our validation set from file
            if strcmp(dataset,'file')
                m.logger.fine('Validation set will be read from file');
                
                % read xml-data from config file
                se = config.self.selectSingleNode('SampleEvaluator');
                
                % check whether SampleSelector field is null
                if isempty(se)
                    msg = 'ValidationSet measure configured to work on file (set=file), but no SampleSelector field present...';
                    m.logger.severe(msg);
                    error(msg);
                end
                
                % instantiate sample evaluator
                m.logger.info('Constructing validationset SampleEvaluator');
                sampleEvaluator = instantiate(se, config);
                m.logger.info(['Created validationset SampleEvaluator of type ' class(sampleEvaluator)]);
                
                % only works with datasets
                if isa(sampleEvaluator, 'ibbt.sumo.sampleevaluators.datasets.DatasetSampleEvaluator')
                    sampleManager = SampleManager(config);
                    [validationSamples, validationValues] = extractRawDataset( sampleEvaluator.getData());
                    sampleManager = add(sampleManager, validationSamples, validationValues);
                    [validationSamples, validationValues] = getInModelSpace(sampleManager);
                    
                    % no dataset - produce error
                else
                    msg = 'You can only use datasets to get the validation set from';
                    m.logger.severe(msg);
                    error(msg);
                end
            else
                m.logger.fine(sprintf('Validation set of %d%% will be created on the fly',percentUsed));
            end
            
            m.percentUsed = percentUsed;
            m.validationSamples = validationSamples;
            m.validationValues = validationValues;
            m.set = dataset;
            m.randomThreshold = randomThreshold;
            
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
    methods(Access = public)
        m = calculateValidationSet(m, samples);
    end
end


