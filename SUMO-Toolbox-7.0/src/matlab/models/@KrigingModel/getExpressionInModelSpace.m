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
% Revision: $Rev: 6401 $
%
% Signature:
%	desc = getExpressionInModelSpace(this, outputIndex)
%
% Description:
%	Returns the closed, symbolic expression (as a string) of the model for the given output number

%% pre-processing
precision = '%.30d';

% input scaling
inputScaling = this.getInputScaling();
% output scaling
outputScaling = this.getOutputScaling(); 

samples = this.getScaledSamples();
inputNames = this.getInputNames();

%% regression part
[dummy regr] = this.regressionFunction('outputIndex', outputIndex, 'latex', false, 'includeCoefficients', true, 'precision', precision );

% replace xl,xq with the real variable names

% apply input scaling
% TODO: levels is now a cell array
% - support for xc, xqua, ... ?
% - use orthogonal polynomial coding formula ?

% atm: Formula only correct if maxOrder = 2
levels = this.getLevels();
if any( cellfun( @length, levels ) ~= 3 ) % if not quadratic
	% NOT supported
	desc = sprintf( 'Expressions are not supported for this regression function %s.', regr );
	return;
end

for i=1:length(inputNames)
	% scaling also needed for correlation part
	inputNames{i} = ['((' inputNames{i} '-' sprintf(precision,inputScaling(1,i)) ') ./ ' sprintf(precision,inputScaling(2,i)) ')'];
	
	% find xl,xq and replace by corresponding scaled+transformed inputName
	% xl = (samples./repmat(levels(end,:).*sqrt(3./2);
    % xq = (3.*(samples./repmat(levels(end,:),n,1)).^2-2)./sqrt(2);
	% Assume one sample at a time (removes repmat)
	
	%xl
	pat = sprintf( 'x%il', i );
	rep = sprintf( '(%s./%.30d).*sqrt(3./2)', inputNames{i}, levels{i}(end) );
	regr = regexprep(regr, pat, rep);
	
	% xq
	pat = sprintf( 'x%iq', i );
	rep = sprintf( '(3.*(%s./%.30d).^2-2)./sqrt(2)', inputNames{i}, levels{i}(end) );
	regr = regexprep(regr, pat, rep);
end


%% correlation part
[dummy corrName] = this.correlationFunction();

corr='+';
hp = this.getHp();
gamma = this.getGamma();
for set=1:size(gamma,1)
	
	% coefficient
	coeff = gamma(set,outputIndex);
	
	% positive coefficient
	if coeff > 0
		
		% append +
		if set > 1; corr = [corr '  + ']; end
		
		% append coefficient
		corr = [corr  sprintf(precision,coeff) ' '];
		
	% negative coefficient
	else
		
		% append spaces
		if set > 1; corr = [corr ' ']; end
		
		% append coefficient
		corr = [corr '- ' sprintf(precision,-coeff) ' '];
	end
	
	% print correlation function r(x) = R(hp, x, samples)
	corr = [corr '.*exp('];
	for var=1:length(hp)
		corr=[corr '-' sprintf(precision,hp(var)) '.*'];
		
		if isequal( corrName, 'corrgauss' )
			corr = [corr '(' inputNames{var} '-' sprintf(precision,samples(set,var)) ').^2'];
		elseif isequal( corrName, 'correxp' )
			corr = [corr 'abs(' inputNames{var} '-' sprintf(precision,samples(set,var)) ')'];
		else
			desc = sprintf( 'Correlation function %s not yet supported.', corrName );
			return;
		end
	end
	corr = [corr ')'];
end

% the complete expression: regression part + correlation part
desc = [regr corr];

% apply output scaling
desc = [sprintf(precision,outputScaling(1,outputIndex)) '+' sprintf(precision,outputScaling(2,outputIndex)) '.*(' desc ')'];
