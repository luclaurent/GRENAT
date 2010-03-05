function res = wrapModels(pop);

% wrapModels (SUMO)
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
%	res = wrapModels(pop);
%
% Description:
%	Wrap the given array of models in WrappedModels

% WrappedModel constructor prevents double wrapping

if(isempty(pop))
  res = [];
  return;
end

if(iscell(pop))
  for c=1:size(pop,1)
	  res(c,1) = WrappedModel(pop{c,1});
  end
else
  for c=1:size(pop,1)
	  res(c,1) = WrappedModel(pop(c,1));
  end
end
