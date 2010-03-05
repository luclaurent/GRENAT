function str = hornerScheme( degrees, dimension )

% hornerScheme (SUMO)
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
%	str = hornerScheme( degrees, dimension )
%
% Description:
%	Generates C code for rational interpolant, used by `export'

if nargin == 1
	dimension = 0;
end

if size(degrees,2) == 1
	assert( size(degrees,1) == 1, '[E] Internal error' );
	str = sprintf( '%f', degrees(1) );
	return
end

degrees = sortrows( degrees );

blocks = [ 0 ;find( degrees(2:end,1) - degrees(1:end-1,1) )];

str = hornerScheme( degrees(blocks(end)+1:end,2:end), dimension+1 );

for j=length(blocks)-1:-1:1
	str = sprintf( '(%s)*x[%d]+(%s)', str, dimension, ...
		hornerScheme( degrees(blocks(j)+1:blocks(j+1),2:end), dimension+1 ) );
end
