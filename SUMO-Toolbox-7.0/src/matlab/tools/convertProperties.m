function o = convertProperties( prop )

% convertProperties (SUMO)
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
%	o = convertProperties( prop )
%
% Description:
%	Converts a properties object (key -> value) to a matlab struct so
%	that struct.key = value

pn = prop.propertyNames();

while pn.hasMoreElements()
	key = char( pn.nextElement() );
	value = char( prop.getProperty( key ) );
	
	% parse text (determine type)
	[numValue, ok] = str2num( value );	
	if strcmpi( value, 'true' ) || strcmpi( value, 'false' ) || ... % boolean
		(ok && ~exist( value, 'builtin' )) % Numeric and not an builtin function ('eps' is numeric)
		o.(key) = numValue;
	else
		o.(key) = value;
	end
end
