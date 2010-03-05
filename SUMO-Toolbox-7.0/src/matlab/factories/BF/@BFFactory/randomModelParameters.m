function modelConfig = randomModelParameters( s )

% randomModelParameters (SUMO)
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
%	modelConfig = randomModelParameters( s )
%
% Description:
%	dummy

dimension = s.dimension;
BFs = getBasisFunctions(s);

functionSelect = randomInt(1,length(BFs),dimension);

BF = struct;
for k=1:dimension
	BFSpec = BFs(functionSelect(k));
	BF(k).name = BFSpec.name;
	BF(k).func = BFSpec.func;
	BF(k).theta = scaleIn( s, rand( 1,length(BFSpec.min) ), BFSpec );
end

posibilities = s.regression;
newRegression = posibilities(randomInt(1,length(posibilities)));

modelConfig = struct( ...
	'func',				BF, ...
	'degrees',			newRegression, ...
	'backend',			s.backend, ...
	'targetAccuracy',	0.005 ...
);
