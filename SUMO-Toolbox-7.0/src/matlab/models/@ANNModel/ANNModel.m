classdef ANNModel < Model

% ANNModel (SUMO)
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
%	ANNModel( varargin )
%
% Description:
%	Constructs a new feedforward Artificial Neural Network (ANN).

    
    properties(Access = private)
        config = struct(...
            'initialWeights', struct('IW',[],'LW',[],'b',[]),...
            'epochs', 300,...
            'trainingTime', Inf,...
            'learningRule', {'trainbr'},...
            'trainingGoal', 0,...
            'networkDim', [2 3 2 1],...
            'transferFunctions', {{'tansig','tansig','purelin'}},...
            'performFcn', {'mse'},...
            'trainMethod',{'auto'},...
            'earlyStoppingRatios', [0.8 0.2 0],...
            'trainingProgress', NaN...
            );
        network;
    end
    
    methods
        function this = ANNModel( varargin )
            
            if(nargin == 0)
                % use defaults
            elseif(nargin == 1)
                this.config = varargin{1};
            elseif(nargin == 3)
                this.config.networkDim = varargin{1};
                this.config.epochs = varargin{2};
                this.config.trainingGoal = varargin{3};
            elseif(nargin == 4)
                this.config.networkDim = varargin{1};
                this.config.epochs = varargin{2};
                this.config.trainingGoal = varargin{3};
                this.config.initialWeights = varargin{4};
            else
                error('Invalid number of parameters given');
            end
            
            % construct the network object
            this = buildNetwork(this);
            
            if(nargin ~= 4)
                %Set the inital weights to the initial weights of the network
                this.config.initialWeights.IW = this.network.IW;
                this.config.initialWeights.LW = this.network.LW;
                this.config.initialWeights.b = this.network.b;
            end
        end
        
        function res = getConfig(this)
            res = this.config;
        end
        
        function res = getNetwork(this)
            res = this.network;
        end
        
        function res = getNetworkDim(this)
            res = this.config.networkDim;
        end
        
        function [w] = getInitialWeights(this)
            w = this.config.initialWeights;
        end
        
        function this = setConfig(this,cfg);
            this.config = cfg;
        end
        
        function this = setLearningRule(this,rule)
            this.config.learningRule = rule;
        end

        function this = setPerformFcn(this,pf)
            this.config.performFcn = pf;
        end

        function this = setEpochs(this,epochs)
            this.config.epochs = epochs;
        end

        function this = setTrainingProgress(this,prog)
            this.config.trainingProgress = prog;
        end
        
        function this = setTransferFunctions(this,tf)
            this.config.transferFunctions = tf;
        end
    
        function values = evaluateInModelSpace( s, points )
            values = sim(s.network,points')';
        end
        
        function s = constructInModelSpace( s, samples, values )
            %Construct base class
            s = s.constructInModelSpace@Model(samples, values);

            %Train the network on the samples
            s = trainNetwork(s,samples,values,true);
        end
        
        function res = complexity(model)
            res = length(getx(model.network));
        end
        
        this = setWeights(this,w);
        this = initFromTrainedNetwork(this,other);
        w = getNetworkWeights(this,asVector);
        this = setInitialWeights(this,w);
        this = randomInit(this,range);
        this = reinit(this);
        res = getHiddenLayerDim(this);
        this = jitterWeights(this);
        desc = getDescription(this);
        
    end
    
    methods(Access = private)
        this = buildNetwork(this);
        this = trainByOptimizer(this,samples,values,op);
        [this net] = trainNetwork(this,net,samples,values,setInitWeights);
        [net tr] = trainWithEarlyStopping(net,samples,values,ratios);
    end
    
end
