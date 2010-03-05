classdef FANNModel < Model

% FANNModel (SUMO)
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
%	FANNModel( varargin )
%
% Description:
%	Constructs a new neural network backed by the FANN library

    properties(Access = private)
        config = struct(...
            'initialWeights',[],...
            'epochs', 1000,...
            'trainingGoal', 0,...
            'networkDim', [2 5 5 1]...
            );
        network;
    end

    methods
        function this = FANNModel( varargin )

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

            this.network = createFann(this.config.networkDim,1);

            if(nargin == 4)
                this.network.weights = this.config.initialWeights;
            else
                this.config.initialWeights = this.network.weights;
            end
        end

        function res = getNetworkDim(this)
            res = this.config.networkDim;
        end

        function [w] = getNetworkWeights(this)
            w = this.network.weights;
        end

        function [w] = getInitialWeights(this)
            w = this.config.initialWeights;
        end

        this = setInitialWeights(this,w);
        this = randomInit(this,range);
        res = getHiddenLayerDim(this);
        this = jitterInitialWeights(this);
        this = constructInModelSpace(this, samples, values);
        [values] = evaluateInModelSpace(this, points);
        desc = getDescription(this);
        res = complexity(this);

    end
end
