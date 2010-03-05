function out = getCandidateDegrees( dim, dj )

% getCandidateDegrees (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	out = getCandidateDegrees( dim, dj )
%
% Description:
%	generates candidate degree matrix for blind kriging
%	based on one or more degree matrices for variable j

	out = dj{dim};
	for i=dim-1:-1:1
		% generate idx'ces
		idx1 = 1:size(out, 1);
		idx1 = idx1( ones(size(dj{i}, 1),1), : );
		idx1 = idx1';
		idx1 = idx1(:);
		
		idx2 = 1:size(dj{i}, 1);
		idx2 = idx2( ones(size(out, 1), 1), : );
		idx2 = idx2(:);
		
		out = out(idx1,:) + dj{i}(idx2,:);
	end
end
