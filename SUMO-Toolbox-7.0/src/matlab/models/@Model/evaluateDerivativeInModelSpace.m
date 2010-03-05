function derivatives = evaluateDerivativeInModelSpace( s, points, outputIndex )

% evaluateDerivativeInModelSpace (SUMO)
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
%	derivatives = evaluateDerivativeInModelSpace( s, points, outputIndex )
%
% Description:
%	Approximate the derivative at the given points in model space.  It will return the gradient in each dimension.
%	This is just a very simple implementation based on a simple symmetric approximation.
%	Note that models can override this with more efficient implementations.  For example Rational/Polynomial models
%	would be able to provide exact derivatives.  The same goes for Kriging models.
%
%	For a good tutorial/intro on gradients see: http://www-math.mit.edu/18.013A/HTML/chapter07/contents.html

% small magic number
d = 1e-5;

[ni no] = getDimensions(s);
numPoints = size(points,1);

delta = ones(numPoints,1)*d;

% return the gradient in each input dimension
derivatives = zeros(numPoints,ni);

for i=1:ni
  pRight = points;
  pLeft = points;

  % use a symmetric approximation
  pRight(:,i) = pRight(:,i) + delta;
  pLeft(:,i) = pLeft(:,i) - delta;

  % evaluate the model in the deviated points
  vRight = evaluateInModelSpace(s, pRight);
  vLeft = evaluateInModelSpace(s, pLeft);
  
  % select the appropriate output
  vRight = vRight(:,outputIndex);
  vLeft = vLeft(:,outputIndex);

  % calculate the gradient of the line connecting the upper and lower points
  derivatives(:,i) = (vRight - vLeft) ./ 2*d;
end
