function [transf] = getTransformationValues(s)

% getTransformationValues (SUMO)
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
%	[transf] = getTransformationValues(s)
%
% Description:
%	Get a function that transforms input from simulator space to model
%	space and back again. inFunc is simulator -> model space, outFunc is
%	model -> simulator space.

% simulator -> model space
translate = s.translate;
scale = s.scale;

% put them in one matrix
transf = [translate ; scale];

% model space -> simulator space
%{
outFunc = @(y)( ...
constantValues(ones(size(y,1),1),:) ... % replicate constant mask, once for each sample passed
+ bsxfun(@times, ~constantMask, ... % for the 'normal' inputs, we assign the transformed input values
(y(:, sumMask) .* scale(ones(size(y,1),1),sumMask)) + translate(ones(size(y,1),1),sumMask)) ... % transform 'normal' inputs to simulator space
);
%}
%outFunc = @(y)(y .* scale(ones(size(y,1),1),:) + translate(ones(size(y,1),1),:)); % transform 'normal' inputs to simulator space

% simulator space -> model space
% filter out the non-constant dimensions first
%inFunc = @(x)((x(:, ~constantMask) - translate(ones(size(x,1),1),:)) ./ scale(ones(size(x,1),1),:));
%inFunc = @(x)((x - translate(ones(size(x,1),1),:)) ./ scale(ones(size(x,1),1),:));
