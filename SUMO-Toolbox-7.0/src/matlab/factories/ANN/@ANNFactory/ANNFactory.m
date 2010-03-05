classdef ANNFactory < GeneticFactory

% ANNFactory (SUMO)
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
%	ANNFactory(config)
%
% Description:
%	This class is responsible for generating ANN models based on the Matlab ANN toolbox

    
    properties(Access = private)
        initialSize;
        epochs;
        allowedLearningRules;
        trainingTime;
        trainingGoal;
        initWeightRange;
        hiddenUnitDelta;
        hiddenUnitBounds;
        transferFunctionTemplate;
        performFcn;
        trainMethod;
        trainingProgress;
        earlyStoppingRatios;
        logger;
    end
    
    methods
        function this = ANNFactory(config)
            import java.util.logging.*;
            import ibbt.sumo.config.*
            
            this = this@GeneticFactory(config);
            
            allowedRules = stringSplit(char(config.self.getOption('allowedLearningRules', 'trainbr,trainlm')),',');
            tfunctions = stringSplit(char(config.self.getOption('transferFunctionTemplate','tansig,purelin')),',');
            
            if(length(tfunctions) ~= 2)
                error('The transfer function template should always contain two entries!');
            end
            
            this.initialSize = str2num(char(config.self.getOption('initialSize','3,2')));
            this.epochs = config.self.getIntOption('epochs',300);
            this.allowedLearningRules = allowedRules;
            this.trainingTime = str2num(char(config.self.getOption('trainingTime','Inf')));
            this.trainingGoal = config.self.getDoubleOption('trainingGoal',0);
            this.initWeightRange = str2num(char(config.self.getOption('initWeightRange', '-0.8,0.8')) );
            this.hiddenUnitDelta = str2num(char(config.self.getOption('hiddenUnitDelta', '-2,3')) );
            %  the hidden unit bounds are only used for model builders other than genetic_custom
            this.hiddenUnitBounds = str2num(char(config.self.getOption('hiddenUnitBounds', '0,30')) );
            this.transferFunctionTemplate = tfunctions;
            this.performFcn = char(config.self.getOption('performFcn','mse'));
            this.trainMethod = char(config.self.getOption('trainMethod','auto'));
            this.trainingProgress = str2num(char(config.self.getOption('trainingProgress','NaN')) );
            this.earlyStoppingRatios = str2num(char(config.self.getOption('earlyStoppingRatios','0.80,0.20,0')));
            
            this.logger = Logger.getLogger('Matlab.ANNFactory');
        end
        
        function res = getTransferFunTemplate(this)
            res = this.transferFunctionTemplate;
        end
        
        function res = getTrainMethod(this);
            res = this.trainMethod;
        end
        
        function res = getTrainingTime(this);
            res = this.trainingTime;
        end
        
        function res = getTrainingProgress(this);
            res = this.trainingProgress;
        end
        
        function res = getTrainingGoal(this);
            res = this.trainingGoal;
        end
        
        function res = getPerformFcn(this);
            res = this.performFcn;
        end
        
        function res = getInitWeightRange(this);
            res = this.initWeightRange;
        end
        
        function res = getInitialSize(this);
            res = this.initialSize;
        end
        
        function res = getHiddenUnitDelta(this);
            res = this.hiddenUnitDelta;
        end
        
        function res = getEpochs(this);
            res = this.epochs;
        end
        
        function res = getEarlyStoppingRatios(this);
            res = this.earlyStoppingRatios;
        end
        
        function res = getAllowedLearningRules(this);
            res = this.allowedLearningRules;
        end
        
        %%% Implement ModelFactory
        function res = supportsComplexData(this)
            res = false;
        end
        
        function res = supportsMultipleOutputs(this)
            res = true;
        end
        
        function [LB UB] = getBounds(this)
            [samples values] = getSamples(this);
            
            if(isempty(samples) || isempty(values))
                LB = [this.hiddenUnitBounds(1) this.hiddenUnitBounds(1)];
                UB = [this.hiddenUnitBounds(2) this.hiddenUnitBounds(2)];
            else
                dim = networkDimFromSamples(size(samples,1),size(samples,2),size(values,2),0.3);
                LB = [0 0];
                UB = [dim];
                if(length(UB) == 1)
                    UB = [dim dim];
                end
            end
        end
        
        models = createInitialModels(this,number,wantModels);
        model = createModel(this,parameters);
        model = createRandomModel(this);
        obs = getObservables(this);
        
        %%% Implement GeneticFactory
        function res = getModelType(this)
            res = 'ANNModel';
        end
        
        obs = getBatchObservables(this);
        mutationKids = mutation(this, parents, options, nvars, FitnessFcn, state, thisScore, thisPopulation);
        xoverKids = crossover(this, parents, options, nvars, FitnessFcn, unused,thisPopulation)
    end
end
