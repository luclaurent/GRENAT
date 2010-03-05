function child = crossoverANN(s, parent1, parent2)

% crossoverANN (SUMO)
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
%	child = crossoverANN(s, parent1, parent2)
%
% Description:
%	A Simple crossover operator that produces a child based on two parents

dim1 = getHiddenLayerDim(parent1);
dim2 = getHiddenLayerDim(parent2);

%Do a simple 1point crossover of the hidden layers
%randomly choose one of the two possible children
if(dim1 == dim2)
    %If the dims are equal do a single point crossover on the weights
    w1 = getNetworkWeights(parent1,1);
    w2 = getNetworkWeights(parent2,1);
    k = randomInt([1 size(w1,1)-1]);
    
    if(rand < 0.5)
        w = [w1(1:k,1); w2(k+1:end,1)];
    else
        w = [w2(1:k,1); w1(k+1:end,1)];
    end
    
    if(rand > 0.5)
        child = setWeights(parent1,w);
    else
        child = setWeights(parent2,w);
    end
    % Add some jitter
    child = jitterWeights(child);
else
    if(rand < 0.5)
        newDim = [dim1(1) dim2(2)];
    else
        newDim = [dim2(1) dim1(2)];
    end
    
    % construct the model
    child = s.createModel(newDim);
    
    %Initialize the weights with one of the parents
    if(rand <= 0.5)
        child = initFromTrainedNetwork(child,parent1);
    else
        child = initFromTrainedNetwork(child,parent2);
    end
    child = jitterWeights(child);
end

