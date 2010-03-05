function [s] = runLoop( s )

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
% Revision: $Rev: 6376 $
%
% Signature:
%	[s] = runLoop( s )
%
% Description:
%	Main adaptive modeling code. Just randomly create new models

% get samples and values
[samples,values] = getData( s );

% set the data
mi = getModelFactory( s );
mi = setSamples(mi,samples,values);
s = setModelFactory(s,mi);

% Generate a set of random models from the model factory
models = [];
for i=1:s.runSize
	models = [models ; createRandomModel( mi )];
end

% Score the models against the measures.  It is more efficient if we do them all
% in one go, instead of one by one.
[scores s scoredModels] = defaultFitnessFunction(s, models, 1);
