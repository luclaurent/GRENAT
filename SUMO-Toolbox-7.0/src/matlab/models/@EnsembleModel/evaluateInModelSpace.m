function values = evaluateInModelSpace( s, points )

% evaluateInModelSpace (SUMO)
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
%	values = evaluateInModelSpace( s, points )
%
% Description:
%	Evaluation at a set of points

%Return the weighted average prediction
[in out] = getDimensions(s);

values = zeros(size(points,1),out);

for i=1:length(s.models)
	values = values + (s.weights(i) .* evaluateInModelSpace( s.models{i}, points ) );
end
