function obs = getBasicBatchObservables( s )

% getBasicBatchObservables (SUMO)
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
%	obs = getBasicBatchObservables( s )
%
% Description:
%	Generate the observable objects that handle grouped data

observables = getObservables( s );
nObservables = length(observables);

obs = cell( 2*nObservables,1 );

for k=1:nObservables
	obs{2*k-1} = BatchObservable( 'best', 'Hyperparameters of the best model per generation', observables{k}, 'best' );
	obs{2*k}   = BatchObservable( 'spread', 'Spread of the hyperparameters per generation (min,max,median)', observables{k}, 'spread' );
end
