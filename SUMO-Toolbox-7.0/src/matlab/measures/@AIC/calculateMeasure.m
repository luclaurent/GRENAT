function [m, newModel, score] = calculateMeasure(m, model, context, outputIndex)

% calculateMeasure (SUMO)
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
%	[m, newModel, score] = calculateMeasure(m, model, context, outputIndex)
%
% Description:
%	Returns the Akaike evidence ratio for this model relative to the best model

%Model remains unchanged
newModel = model;

aic = calculateAIC(model);
aic = aic(outputIndex);

if(m.useEvidenceRatios)
    %Get the best models
    models = context.bestModels;

    %If this is the very first model...
    if(isempty(models))
        aic = zeros(1,length(outputIndex));
    else
        % put the current best model first
        models = {models{1} model};

        %Get all relevant Akaike metrics
        [delta weights likelihood evidence] = getAICInfo(models);
        %Get the evidence for the given model (higher is better)
        aic = evidence(:,2)';
    end

    %The bigger the evidence, the better the model
    %The evidence is maximally 1 (if the given model is the best model), add 1 to prevent immediate termination on target = 0
    score = (1 - aic) + 1;

else
   score = aic;
   % This is not strictly necessary but it means you dont have to go figuring out targets and can just leave them at 0
   score = score + 1e6;
end
