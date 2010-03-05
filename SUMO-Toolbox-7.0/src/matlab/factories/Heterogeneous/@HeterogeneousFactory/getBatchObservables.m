function obs = getBatchObservables( s )

% getBatchObservables (SUMO)
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
%	obs = getBatchObservables( s )
%
% Description:

obs = getBasicBatchObservables( s );

mis = getModelFactories( s );
types = cell(size(mis));
for i=1:length(mis)
	types{i} = getModelType(mis{i});
end

% Monitor the composition of the population
obs{end+1} = CategoriesObservable( 'share', 'Share of each model type in the total population', types );


% Add one more to trace the composition of the best ensemble

% Get the type of model that each interface produces
% this is needed so it can be matched with the types of model
% present in the ensemble
ifs = getModelFactories( s );
types = {};
for i=1:length(ifs)
	if(~isa(ifs{i},'EnsembleGeneticInterface'))
		types = [types getModelType(ifs{i})];
	end
end

obs{end+1} = EnsembleObservable( 'ensembleComposition', 'Composition of the best ensemble in the population', types);
