function [LB UB] = getBounds(s)

% getBounds (SUMO)
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
%	[LB UB] = getBounds(s)
%
% Description:
%	Return the lower and upper bounds (in the original simulator space) of each model input

% get the transformation functions
[inFunc outFunc] = getTransformationFunctions(s);

% get the number of inputs
[ni no] = getDimensions(s);

% the lower bound in model space is -1, the upper bound is +1
lpoints = -ones(1,ni);
upoints = ones(1,ni);

% transform the points from model space to simulator space
LB = outFunc(lpoints);
UB = outFunc(upoints);
