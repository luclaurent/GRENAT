function bf = translateBasisFunction( s )

% translateBasisFunction (SUMO)
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
%	bf = translateBasisFunction( s )
%
% Description:
%	Translate the basis function name to the format required by the different libraries

switch s.config.backend
	case 'FastRBF'
		switch s.config.func.name
			case 'rbfMultiquadric'
				bf = 'multi';
			case 'rbfBiharmonic'
				bf = 'biharm';
			case 'rbfTriharmonic'
				bf = 'triharm';
			otherwise
				msg = sprintf( 'Basis function `%s'' not supported with FastRBF backend', s.config.RBF );
				s.logger.severe(msg);
				error(msg);
			end
	case {'Direct','direct','AP','Greedy'}
		bf = s.config.func.func;
	otherwise
		msg = sprintf( 'Backend type `%s'' not supported by RBFModel', s.config.backend );
		s.logger.severe(msg);
		error(msg);
end
