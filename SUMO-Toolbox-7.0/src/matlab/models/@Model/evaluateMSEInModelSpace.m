function values = evaluateMSEInModelSpace( s, points )

% evaluateMSEInModelSpace (SUMO)
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
%	values = evaluateMSEInModelSpace( s, points )
%
% Description:
%	Fallback. when called it means that that model type does not support mean square error

msg = sprintf('%s does not support point-wise error estimation. At the moment only Kriging, GP, DACE, RBF and SVM (partially) support this.',class(s));

error(msg);
