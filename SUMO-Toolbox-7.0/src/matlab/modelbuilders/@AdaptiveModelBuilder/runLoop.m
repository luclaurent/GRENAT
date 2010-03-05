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
%	Do nothing really, just return a model with user chosen parameters

mi = getModelFactory( s );

if ~done( s )
	% get samples and values
	[samples,values] = getData( s );

	mi = setSamples(mi,samples,values);
	s = setModelFactory(s,mi);
	
	% Get a new model from the modeller, using the parameters set by the user in the config file
	% Then call the construct method to create a model through the
	% samples and values
	newModel = createModel( mi );

	% Score the model against the measures
	[scores s scoredModels] = defaultFitnessFunction(s, newModel);
end
