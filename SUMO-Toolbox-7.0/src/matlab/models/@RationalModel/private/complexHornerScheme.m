function [realstr,complexstr] = complexHornerScheme( degrees )

% complexHornerScheme (SUMO)
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
%	[realstr,complexstr] = complexHornerScheme( degrees )
%
% Description:
%	Outputs C code for rational interpolant, used by `export'

degrees = sortrows( degrees );
blocks = [ 0 ;find( degrees(2:end,1) - degrees(1:end-1,1) ); size(degrees,1) ];

nblocks = length(blocks) - 1;
lastreal = iff( mod( nblocks, 2 ), nblocks, nblocks-1 );
lastcomplex = iff( mod( nblocks, 2 ), nblocks-1, nblocks );

if lastreal > 0
	realstr = hornerScheme( degrees(blocks(lastreal)+1:blocks(lastreal+1),2:end), 1 );
else
	realstr = '0.0';
end

if lastcomplex > 0
	complexstr = hornerScheme( degrees(blocks(lastcomplex)+1:blocks(lastcomplex+1),2:end), 1 );
else
	complexstr = '0.0';
end

for j=lastreal-2:-2:1
	realstr = sprintf( '-(%s)*square(2+x[0])+(%s)', realstr, ...
		hornerScheme( degrees(blocks(j)+1:blocks(j+1),2:end), 1 ) );
end

for j=lastcomplex-2:-2:1
	complexstr = sprintf( '-(%s)*square(2+x[0])+(%s)', complexstr, ...
		hornerScheme( degrees(blocks(j)+1:blocks(j+1),2:end), 1 ) );
end

complexstr = sprintf( '(%s)*(2+x[0])', complexstr );
