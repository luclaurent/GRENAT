function joined = stringJoin( words, delimiter )

% stringJoin (SUMO)
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
%	joined = stringJoin( words, delimiter )
%
% Description:
%	Join strings

if nargin < 2
	delimiter = ' ';
end

if(isa(words,'char'))
  joined = words;
  return;
end

if length(words) >= 1	
	joined = words{1};
	for k = 2:length(words)
		joined = sprintf( '%s%s%s', joined, delimiter, words{k} );
	end
else
	joined = '';
end
