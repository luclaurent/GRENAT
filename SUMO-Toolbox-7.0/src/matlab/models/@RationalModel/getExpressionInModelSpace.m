function desc = getExpressionInModelSpace(this, outputIndex)

% getExpressionInModelSpace (SUMO)
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
%	desc = getExpressionInModelSpace(this, outputIndex)
%
% Description:
%	Returns the closed formula (as a string) for this rational function

% Get the names of the inputs and outputs
inputNames = getInputNames(this);
outputNames = getOutputNames(this);

% set the base expression function
baseFunctions = cell(1,length(this.baseFunctions));
for i = 1 : length(this.baseFunctions)
	baseName = func2str(this.baseFunctions{i});
	if strcmp(baseName, 'powerBase')
		baseFunctions{i} = @getPowerBaseExpression;
	elseif strcmp(baseName, 'chebyshevBase')
		baseFunctions{i} = @getChebyshevBaseExpression;
	else
		msg = sprintf('Expressions are not supported for basis function %s.', baseName);
		desc = msg;
		return;
	end
end

% get degrees
[numdegrees,dendegrees] = getDegrees( this.degrees, this.freedom );

% How to print coeficients (see the sprintf syntax)
precision = '%0.6d';

% print numerator
num = '';
for set = 1 : size(numdegrees,1)
	
	% coefficient
	coeff = this.numerator{outputIndex}(set);

	% complex coefficient
	if ~isreal(coeff)
		
		% append +
		if set > 1; num = [num '  + ']; end
		
		% add coefficient
		num = [num '(' num2str(coeff) ') '];
		
	% real coefficient
	else
		
		% positive coefficient
		if coeff > 0

			% append +
			if set > 1; num = [num '  + ']; end

			% append coefficient
			num = [num  sprintf(precision,coeff) ' '];

		% negative coefficient
		else

			% append spaces
			if set > 1; num = [num ' ']; end

			% append coefficient
			num = [num '- ' sprintf(precision,-coeff) ' '];
		end
	end
	
	% print exponents
	for var = 1 : size(numdegrees,2)
		if numdegrees(set,var) > 0
			if var > 1; num = [num ' ']; end
			if var == this.frequencyVariable
				num = [num ' * ' baseFunctions{var}(['(1i*(2+' inputNames{var} '))'], numdegrees(set,var))];
			else
				num = [num ' * ' baseFunctions{var}(inputNames{var}, numdegrees(set,var))];
			end
		end
	end
end

% print denominator if there is one
if size(dendegrees,1) ~= 0
	
	den = '1';
	for set = 1 : size(dendegrees,1)

		% coefficient
		coeff = this.denominator{outputIndex}(set);

		% complex coefficient
		if ~isreal(coeff)

			% append +
			den = [den '  + '];

			% add coefficient
			den = [den '(' num2str(coeff) ') '];
			
		% real coefficient
		else
		
			% positive coefficient
			if coeff > 0

				% append +
				den = [den ' + '];

				% append coefficient
				den = [den sprintf(precision,coeff) ' '];

			% negative coefficient
			else

				% append spaces
				if set > 1; den = [den ' ']; end

				% append coefficient
				den = [den '- ' sprintf(precision,-coeff) ' '];
			end
		end

		% print exponents
		for var = 1 : size(dendegrees,2)
			if dendegrees(set,var) > 0
				if var > 1; den = [den ' ']; end
				if var == this.frequencyVariable
					den = [den ' * ' baseFunctions{var}(['(1i*(2+' inputNames{var} '))'], dendegrees(set,var))];
				else
					den = [den ' * ' baseFunctions{var}(inputNames{var}, dendegrees(set,var))];
				end
				
			end
		end
	end
	
	desc = sprintf('(%s)/(%s)', num, den);

% no denominator, just print numerator
else
	desc = num;
end
