classdef CrossValidation < Measure

% CrossValidation (SUMO)
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
%	CrossValidation(varargin)
%
% Description:
%	This measure uses k-fold crossvalidation to gauge the accuracy of the model

    
    
    properties(Access = private)
        numFolds;
        dimension;
        folds;
        qqdata = [];
        resetFolds;
        randomThreshold;
        partitionMethod;
        logger;
    end
    
    methods(Access = public)
        
        function m = CrossValidation(varargin)
            import java.util.logging.*;
            import ibbt.sumo.config.*;
            
            logger = Logger.getLogger('Matlab.measure.CrossValidation');
            
            if nargin == 1
                config = varargin{1};
                
                % number of folds
                numFolds = config.self.getIntOption('folds', 5);
                
                % generate fold structure
                folds = cell(1,numFolds);
                fold = struct('size', 0, 'testSet', []);
                for i = 1 : numFolds
                    folds{i} = fold;
                end
                
                partitionMethod = char(config.self.getOption('partitionMethod','uniform'));
                if strcmp(partitionMethod, 'distance')
                    partitionMethod = 'uniform';
                end
                
               dim = config.input.getInputDimension();
               resetFolds = config.self.getBooleanOption('resetFolds',0);
               randomThreshold = config.self.getIntOption('randomThreshold',1000);
                
               superArgs = {config};
                
            elseif(nargin == 2)
                
                % number of folds
                numFolds = varargin{1};
                
                % generate fold structure
                folds = cell(1,numFolds);
                fold = struct('size', 0, 'testSet', []);
                for i = 1 : numFolds
                    folds{i} = fold;
                end
                
                partitionMethod = 'uniform';
                dim = varargin{2};
                resetFolds = 1;
                randomThreshold = 1000;
                
                superArgs = {};
            else
                error('Invalid number of arguments given')
            end
            
            m = m@Measure(superArgs{:});
            
            m.numFolds = numFolds;
            m.dimension = dim;
            m.folds = folds;
            m.partitionMethod = partitionMethod;
            m.resetFolds = resetFolds;
            m.randomThreshold = randomThreshold;
            m.logger = logger;
            
            % random & resetFolds false, fix to true
            if strcmp(m.partitionMethod, 'random') && ~m.resetFolds
                m.resetFolds = true;
                m.logger.warning('CrossValidation: partition method set to random, so resetFolds automatically set to true');
            end
            
            if m.numFolds < 2
                msg = 'Number of folds should be larger than 1';
                m.logger.severe(msg);
                error(msg);
            end
        end
        
        function [qqdata] = getQQPlotData(this)
            qqdata = this.qqdata;
        end
        
        [m, newModel, score] = calculateMeasure(m, model, context, outputIndex);
    end
    
end



