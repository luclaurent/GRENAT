function gridParameters = createGridParameters(importanceParameters, points)

% createGridParameters (SUMO)
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
%	gridParameters = createGridParameters(importanceParameters, points)
%
% Description:
%	Solve equation :
%	{ ax + by      = 0
%	{      cy + dz = 0
%	{          xyz = e
%	<=>
%	{ ax = -by
%	{ cy = -dz
%	{ xyz = e
%	<=>
%	{ x = (-b/a)y
%	{ y = (-d/c)z
%	{ xyz = e
%	<=>
%	{ x/y = -b/a
%	{ y/z = -d/c
%	{ xyz = e
%	<=>
%	{ logx - logy = -log(b/a)
%	{ logy - logz = -log(d/c)
%	{ logx + logy + logz = loge
%
%	Example: createGridParameters([2,5,10], 50)
%	{ logx - logy = -log(2/5)
%	{ logy - logz = -log(5/10)
%	{ logx + logy + logz = log(50)
%	solution: [2,4,8]

dimension = size(importanceParameters,2);

A = zeros(dimension);
B = zeros(dimension,1);
for i = 1:dimension-1
	A(i,i) = 1;
	A(i,i+1) = -1;
	B(i) = -log(importanceParameters(i+1)/importanceParameters(i));
end
A(dimension,:) = 1;
B(dimension) = log(points);

gridParameters = linsolve(A,B)';
gridParameters = round(exp(gridParameters));
