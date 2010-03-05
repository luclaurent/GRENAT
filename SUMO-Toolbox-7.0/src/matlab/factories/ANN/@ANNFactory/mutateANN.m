function child = mutateANN(s, parent)

% mutateANN (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	child = mutateANN(s, parent)
%
% Description:
%	Return a mutated neural network

if(rand < 0.5)
    %Simply mutate the weights
    if(rand <= 0.4)
        if(rand < 0.5)
            %Simply re-init the weights using the default matlab function
            child = reinit(parent);
        else
            %Randomly initialize
            child = randomInit(parent, getInitWeightRange(s));
        end
    else
        %Jitter the weights
        child = jitterWeights(parent);
    end
else
    %Mutate the hidden layer structure
    hidLayerDim = getHiddenLayerDim(parent);
    delta = randomInt(getHiddenUnitDelta(s));
    
    %Find out which layer to mutate
    if rand < 0.5
        %Mutate the first hidden layer
        hidLayerDim(1) = hidLayerDim(1) + delta;
    else
        %Mutate the second hidden layer
        hidLayerDim(2) = hidLayerDim(2) + delta;
    end
    
    % construct the model
    child = s.createModel(hidLayerDim);
    
    if(rand > 0.8)
        % choose a random training function
        child = setLearningRule(child, randomChoose(getAllowedLearningRules(s)));
    end
    
    if(rand < 0.5)
        %Init the weights based on the trained weights of the parent network
        child = initFromTrainedNetwork(child,parent);
        child = jitterWeights(child);
    end
end
