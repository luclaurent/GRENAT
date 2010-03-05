function obs = getObservables( s )

% getObservables (SUMO)
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
%	obs = getObservables( s )
%
% Description:
%	Returns observables

modelType = iff( s.dimension == 1, 'RBFModel', 'DACEModel' );

obs = { ...
	SimpleObservable( ...
		'regr', 'Regression degree', modelType, ...		
		@(x) extractField( x, 'config.degrees' ) ) ...
};

for d=1:s.dimension
	for k=1:length(s.functions)
		obs{end+1} = SimpleObservable( ...
			sprintf( 'shape_%d_%s', d, s.functions(k).name ), ...
			sprintf( 'Shape parameters for the i''th dimension when using basis function %s', s.functions(k).name ), ...
			modelType, ...
			@(x) functor( x,d,s.functions(k).name ), ...
 			length( s.functions(k).min ) );
	end
end

function y = functor( x, d, f )

tmp = extractField( x, 'config.func' );
if strcmp( f, tmp(d).name )
	y = tmp(d).theta;
	y = y(:);
else
	y = [];
end
