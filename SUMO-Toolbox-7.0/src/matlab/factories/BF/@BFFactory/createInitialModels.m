function res = createInitialModels(s, number, wantModels);

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
%	res = createInitialModels(s, number, wantModels);
%
% Description:
%	Constructor

%Get the default config (from config file)
res = [];
[smp val] = getSamples(s);

if(number == 1)
	params = rand(1,s.nfree);

	if(wantModels)
	  res = s.createModel(params);
	else
	  res = params;
	end
else
	if(wantModels)
	  for i=1:number
	    m = makeModel( s, randomModelParameters(s) );
	    res = [res ; m];
	  end
	else
	  d = LatinHypercubeDesign(s.nfree,number);
	  [params dummy] = generate(d);
	  res = params;
	end
end
