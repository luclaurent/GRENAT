function s = addParentLink(s, samples, values, A, B)

% addParentLink (SUMO)
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
%	s = addParentLink(s, samples, values, A, B)
%
% Description:
%	Add parent link between A and B
%	N(A) = neighbourhood(A)

% try to add A to N(B)
[s, c1] = addSampleToNeighbourhood(s, samples, B, A);

% try to add B to N(A)
[s, c2] = addSampleToNeighbourhood(s, samples, A, B);

% now update the gradient plane for A if B was added to N(A)
if c2
	
	% update the gradient estimations for all the outputs
	for i = 1 : size(values,2)
		s.gradients{A}(i,:) = convergeGradient(s, samples, values, A, i, s.gradients{A}(i,:));
	end
	
	% now update the gradient error
	s = updateGradientError(s, samples, values, A);
	
end

% now update the gradient plane for B of A was added to N(B)
if c1
	for i = 1 : size(values,2)
		s.gradients{B}(i,:) = convergeGradient(s, samples, values, B, i, s.gradients{B}(i,:));
	end
	
	% now update the gradient error
	s = updateGradientError(s, samples, values, B);
	
end
