function res = createInitialModels(this, number, wantModels)

% createInitialModels (SUMO)
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
%	res = createInitialModels(this, number, wantModels)
%
% Description:
%	Return 'number' individuals.  If wantModels is false only return a parameter matrix where each row
%	uniquely represents one model.  If wantModels is true an array of model objects is returned.

res = [];
params = [];

%[ni no] = getDimensions(s);
[lb,ub] = this.getBounds();
nrHyperparameters = length(lb);

if(number == 1)
	%TODO intelligent guess, now just take the middle
	% how about (lb*ub^7)^(1/8) ? (comes from wiki)
	params = lb + ((ub - lb) ./ 2);
else
	%Create a nD latin hypercube space filling design in [-1 1]
	d = LatinHypercubeDesign(nrHyperparameters,number);
	[smp dummy] = generate(d);

	%scale to proper range, there is a theta for each dimension and each can have its own range
	for i=1:nrHyperparameters
		smp(:,i) = scaleColumns(smp(:,i),lb(i),ub(i));
	end

	params = smp;
end

if(wantModels)
	%Pre-allocate the models
	res = repmat(KrigingModel(),number,1);

	for i=1:number

		m = this.createModel(params(i,:));
		res(i,1) = m;
	end

else
	res = params;	
end
