function [inFunc, outFunc] = calculateTransformationFunctions(transf)

% calculateTransformationFunctions (SUMO)
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
%	[inFunc, outFunc] = calculateTransformationFunctions(transf)
%
% Description:
%	Calculate a simulator -> model space and model -> simulator space
%	function handle for scaling and translating the inputs.

translate = transf(1,:);
scale = transf(2,:);

% model space -> simulator space
outFunc = @(y)(y .* scale(ones(size(y,1),1),:) + translate(ones(size(y,1),1),:)); % transform 'normal' inputs to simulator space

% simulator space -> model space
inFunc = @(x)((x - translate(ones(size(x,1),1),:)) ./ scale(ones(size(x,1),1),:));


end
