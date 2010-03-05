function y = dB( x )

% dB (SUMO)
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
%	y = dB( x )
%
% Description:
%	Returns the absolute value of the parameter in decibel scale.
%
%	Example:
%	>> dB( [ -10 100i ; 1000 -10000i ] )
%	ans =
%	20.0000   40.0000
%	60.0000   80.0000

y = 20*log10(abs(x)+1e-20);
