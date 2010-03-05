function [this,newModel] = createFromHistory(this, history)

% createFromHistory (SUMO)
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
%	[this,newModel] = createFromHistory(this, history)
%
% Description:
%	Create a new ANN model based on the history of models built previously

if(length(history.models) < 1)
    % create a default model based on the config
    newModel = this.createInitialModels(1,1);
elseif(length(history.models) == 1)
    % mutate the model
    newModel = this.mutateANN(history.models(1));
elseif(length(history.models) == 2)
    % perform crossover
    newModel = this.crossoverANN(history.models(1),history.models(2));
else
    % order by score
    [y I] = sort(history.scores);
    
    % alternate between producing a model through mutation or crossover
    if(mod(history.runLength,2) == 1)
        % mutate the worst model
        newModel = this.mutateANN(history.models(I(end)));
    else
        % crossover the two best models
        newModel = this.crossoverANN(history.models(I(1)),history.models(I(2)));
    end    
end
