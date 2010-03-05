function res = unWrapModels(varargin);

% unWrapModels (SUMO)
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
%	res = unWrapModels(varargin);
%
% Description:
%	Unwrap the given array of WrappedModels

if(nargin == 1)
  pop = varargin{1};
  toCell = 0;
elseif(nargin == 2)
  pop = varargin{1};
  toCell = varargin{2};
else
  error('Invalid number of parameters');
end

if(isempty(pop))
  if(toCell)
    res = {};
  else
    res = [];
  end
  return;
end

if(toCell)
  for c=1:size(pop,1)
	  res{c,1} = unWrapModel(pop(c,1));
  end
else
  for c=1:size(pop,1)
	  res(c,1) = unWrapModel(pop(c,1));
  end
end
