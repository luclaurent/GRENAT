function s = runLoop(s)

% runLoop (SUMO)
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
%	s = runLoop(s)
%
% Description:
%	Main adaptive modelling code. Just sequentially
%	create new models (by calling the modelInterface's
%	`create' method) and score them, keeping a history
%	window of `historySize' models.

% get samples and values
[samples,values] = getData(s);

% create empty model
newModel = EmptyModel();
newModel = newModel.construct(samples, values);

% score the model
[s,scores,allMeasureScores,newModel] = scoreModels(s, {newModel});

end
