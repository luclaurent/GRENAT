function values = evaluateDerivative( s, points, outputIndex )

% evaluateDerivative (SUMO)
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
%	values = evaluateDerivative( s, points, outputIndex )
%
% Description:
%	Approximate the derivative at the given points in simulator space.  This function transforms the points
%	to model space and calls evaluateDerivativeInModelSpace

[ni no] = getDimensions(s);

% transform points to model space
[inFunc outFunc] = getTransformationFunctions(s);
points = inFunc(points);

if(~exist('outputIndex','var'))
  outputIndex = 1;
end

if(length(outputIndex) > 1 || outputIndex > no || outputIndex < 1)
  error(sprintf('Invalid output index, must be a number between 1 and %d',no));
end

% call the model space version (works in [-1 1])
values = evaluateDerivativeInModelSpace(s, points, outputIndex);
