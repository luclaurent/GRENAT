function [newA, newB] = linearEquationToModelSpace(this, A, B)

% linearEquationToModelSpace (SUMO)
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
%	[newA, newB] = linearEquationToModelSpace(this, A, B)
%
% Description:
%	Converts coefficients of the linear (in)equation Ax = B to model space
%	- Transformation
%	- insert dummy values
%	- input select

%% Shuffle coefficients around and insert dummy coefficients for dummy
%% values

%% TODO: does same work like transformation function but on linear equations. Code should be checked to see if transformation still holds.

% Create fixed array, initialized to zero (do allocation here)
tempA = zeros(size(A,1), this.dimension);
tempB = B;

for m = 1 : length(this.inputs)
	input = this.inputs(m);

	% get type
	type = char(input.getType());

	switch (type)

		% if dummy, add a coefficient of 0 so it doesn't count
		case 'dummy'
			tempA(:,m) = 0.0;
		% not dummy, shuffle it to the correct position
		case 'normal'
			index = input.getInputSelect() + 1;
			tempA(:,m) = A(:,index);
		otherwise
			error(sprintf('Invalid type %s',type));
	end
end

%% Apply transformation
newA = tempA .* this.scale;
newB = B + sum(tempA .* this.translate, 2);
