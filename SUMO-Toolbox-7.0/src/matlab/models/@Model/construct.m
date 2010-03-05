function s = construct( s, samples, values )

% construct (SUMO)
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
%	s = construct( s, samples, values )
%
% Description:
%	Constructs the model given the samples and values in simulator space.
%	This function scales the data to model space and calls constructInModelSpace()

if(isempty(s.transformationValues))
	% Set the sample scaling stuff if not already done (scoreModel usually sets them)
	
	inDim = size(samples,2);
	
	transl = zeros(1,inDim);
	scale = zeros(1,inDim);
	
	for i = 1:inDim
		% get the minimum/maximum from the samples
		mn = min(samples(:,i));
		mx = max(samples(:,i));
	
		% values for scaling to [-1 1]
		transl(i) = (mx+mn)/2.0;
		scale(i) = (mx-mn)/2.0;
	end
	
	% put them in one matrix and save them
	transf = [transl ; scale];
	s.transformationValues = transf;
end

% transform points to model space
[inFunc outFunc] = getTransformationFunctions(s);
samples = inFunc(samples);

% call the model space version
s = constructInModelSpace( s, samples, values );
