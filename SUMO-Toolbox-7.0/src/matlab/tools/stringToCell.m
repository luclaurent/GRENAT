function result = stringToCell( str )

% stringToCell (SUMO)
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
%	result = stringToCell( str )
%
% Description:
%	Take the string 'str' and split it into a 2 dimensional cell array
%	like as str2num does for numeric matrices
%	This means that ';' delimits rows of the cell array and ',' or ' '
%	delimits columns

result = {};
rows = stringSplit(str,';');

k=1;
for i=1:length(rows)
    cols = stringSplit(rows{i},',| ',true);
    l = 1;
    for j=1:length(cols)
        tmp = strtrim(cols{j});
        if(~isempty(tmp))
            result{k,l} = tmp;
            l = l + 1;
        end
    end
    k = k + 1;
end

