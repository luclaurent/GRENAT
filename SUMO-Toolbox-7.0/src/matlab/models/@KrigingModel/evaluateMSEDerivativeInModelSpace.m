function derivatives = evaluateMSEDerivativeInModelSpace(this, points, outputIndex)

% evaluateMSEDerivativeInModelSpace (SUMO)
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
% Revision: $Rev: 6401 $
%
% Signature:
%	derivatives = evaluateMSEDerivativeInModelSpace(this, points, outputIndex)
%
% Description:
%	Evaluate the derivative of the prediction at the given points

derivatives = zeros( size(points) );
% IMPORTANT: predict_derivatives accepts on point at a time
for i=1:size(points,1)
	[dummy jacobian] = this.predict_derivatives( points(i,:) );
		
	% jacobian: each row is a gradient vector for a particular
	% output -> pick the right row
	derivatives(i,:) = jacobian(outputIndex, :);
end
