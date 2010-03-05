function values = evaluateInModelSpace( s, points )

% evaluateInModelSpace (SUMO)
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
%	values = evaluateInModelSpace( s, points )
%
% Description:
%	Evaluate @ discrete points, given by the M \times dim
%	array points.

if(strcmp(s.config.backend,'SVMlight'))
	values = evaluateSVMlight(s,points);
elseif(strcmp(s.config.backend,'libSVM'))
	values = evaluatelibSVM(s,points);
elseif(strcmp(s.config.backend,'lssvm'))
	values = evaluateLSSVM(s,points);
else
	error(sprintf('Invalid backend %d given',s.config.backend));
end
