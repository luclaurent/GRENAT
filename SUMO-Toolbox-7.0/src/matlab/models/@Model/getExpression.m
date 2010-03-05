function [exp] = getExpression(s,outputIndex)

% getExpression (SUMO)
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
%	[exp] = getExpression(s,outputIndex)
%
% Description:
%	This function first converts the inputs to model space [-1,1] range
%	using the transformation functions and then passes on these functions
%	to the model-space expression.

% get the dimensions
[inDim outDim] = getDimensions(s);

if(~exist('outputIndex','var'))
  outputIndex = 1;
end

if(length(outputIndex) > 1 || outputIndex > outDim || outputIndex < 1)
  error(sprintf('Invalid output index, must be a number between 1 and %d',outDim));
end

% get the parameter names
iNames = getInputNames(s);
oNames = getOutputNames(s);

% get translate/scale vector
translate = s.transformationValues(1,:);
scale = s.transformationValues(2,:);

% transform the separate inputs in one array for easy transformation
pre = '';
for i = 1 : inDim
	pre = [pre sprintf('%s = (%s - %d) ./ %d;\n', iNames{i}, iNames{i}, translate(i), scale(i))];
end

pre = sprintf('%s\n',pre');

% get expression in model space
mexp = getExpressionInModelSpace(s,outputIndex);

% produce final expression
exp = [pre oNames{outputIndex} ' = ' mexp ';'];

end
