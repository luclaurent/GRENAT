function [s, newValues] = filterOutputs(s, unfilteredValues)

% filterOutputs (SUMO)
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
%	[s, newValues] = filterOutputs(s, unfilteredValues)
%
% Description:
%	This method does the actual processing.

% select only those values that are useful to the outputs we want to model
plainValues = unfilteredValues(:,s.outputSelect);


% convert the plain list of real values to a new list,
% based on the type of the outputs we are modeling
newValues = zeros(size(plainValues,1), 0);
for outputType = s.complexHandling
	
	switch outputType{1}
		
		% real parameters are left as they are
		case 'real'
			newValues = [newValues plainValues(:,1)];
			plainValues(:,1) = [];
			
		% complex parameters are built as  the complex combination of two
		% consecutive reals in the plain list
		case 'complex'
			newValues = [newValues (plainValues(:,1) + j*plainValues(:,2))];
			plainValues(:,1:2) = [];
		
		% modulus parameters are built as the abs of the complex
		% combination of two consecutive reals in the plain list
		case 'modulus'
			newValues = [newValues abs(plainValues(:,1) + j*plainValues(:,2))];
			plainValues(:,1:2) = [];
		% calculate the phase (in degrees) of the complex number
		case 'phase'
			%newValues = [newValues 180/pi*(unwrap(angle(plainValues(:,1) + j*plainValues(:,2))))];
			newValues = [newValues 180/pi*(angle(plainValues(:,1) + j*plainValues(:,2)))];
			plainValues(:,1:2) = [];
			
		otherwise
			msg = sprintf('Invalid output type found: %s', outputType{1});
			s.logger.severe(msg);
			error(msg);
	end
	
end

% now apply modifiers to the correct list of new values
for m = 1 : length(s.outputModifiers)
	
	% walk all modifiers for this output and apply them in order
	modifiers = s.outputModifiers{m};
	for n = 1 : length(modifiers)
		
		% apply modifier
		modifier = modifiers{n};
		[newValues(:,m), modifier] = modify(modifier, newValues(:,m));
		modifiers{n} = modifier;
	end
	s.outputModifiers{m} = modifiers;
end
