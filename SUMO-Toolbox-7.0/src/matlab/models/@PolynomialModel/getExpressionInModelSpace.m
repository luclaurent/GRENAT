function desc = getExpressionInModelSpace(s, outputIndex)

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
%	desc = getExpressionInModelSpace(s, outputIndex)
%
% Description:
%	Returns the closed formula (as a string) for this rational function

if ~isequal( s.baseFunctions, cfix( @powerBase, length(s.baseFunctions) ) )
	msg = sprintf( 'Expressions are not supported for basis functions other than powerbase. This polynomial uses %s', func2str( s.baseFunctions{1} ) );
	desc = msg;
	return;
end

% How to print coeficients (see the sprintf syntax)
precision = '%0.15d';
inputNames = getInputNames( s );

% set the base expression function
baseFunctions = cell(1,length(s.baseFunctions));
for i = 1 : length(s.baseFunctions)
	baseName = func2str(s.baseFunctions{i});
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


% print numerator
num = '';
for set = 1 : size(s.degrees,1)
	
	% coefficient
	coeff = s.beta{outputIndex}(set);

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
	for var = 1 : size(s.degrees,2)
		if s.degrees(set,var) > 0
			if var > 1; num = [num ' ']; end
			num = [num ' .* ' baseFunctions{var}(inputNames{var}, numdegrees(set,var))];
		end
	end
end
desc=num;
