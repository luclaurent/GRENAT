function p = normpdfWrapper( x, mu, sigma, override )

% normpdfWrapper (SUMO)
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
%	p = normpdfWrapper( x, mu, sigma, override )
%
% Description:
%	Returns probability
%	 If the Statistics toolbox is not available a custom implementation
%	 will be used. When override is given (value doesn't matter) it will always use the own implementation

	if nargin < 2
		mu = 0;
	end
	if nargin < 3
		sigma = 1;
	end
		
	if license('test', 'statistics_toolbox') && (nargin < 4)
	  p = normpdf( x, mu, sigma );
	else
	  p = exp( ((x-mu).*(x-mu))./(-2.*sigma.*sigma) ) ./ (sigma.*sqrt(2.*pi));		
	end

end
