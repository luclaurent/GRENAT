function printHeteroPop( psize,pop,scores )

% printHeteroPop (SUMO)
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
%	printHeteroPop( psize,pop,scores )
%
% Description:
%	Print the makeup of a heterogeneous population

h=1;
for i=1:length(psize)
	disp(sprintf('  Subpopulation %d',i));
	if(numel(pop)>0)
		for k=1:psize(i)
			p = pop{h};
			%disp(sprintf('    model %d of type %s with score %d',k,p.getDescription(),scores(h)))
			disp(sprintf('    model %d with id %d of type %s with score %d',k,p.getId(),class(p),scores(h)))
			h = h + 1;
		end
	end
end
