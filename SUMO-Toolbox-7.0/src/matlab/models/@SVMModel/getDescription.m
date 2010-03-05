function desc = getDescription( s )

% getDescription (SUMO)
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
%	desc = getDescription( s )
%
% Description:
%	Return a user friendly model description

desc = sprintf('%s SVM with kernel %s, kernel parameter %s, and cost parameter %d',s.config.backend,s.config.kernel,arr2str(s.config.kernelParams),s.config.regularizationParam);
