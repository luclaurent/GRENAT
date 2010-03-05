function m = createModel(s, individual)

% createModel (SUMO)
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
%	m = createModel(s, individual)
%
% Description:
%	Given an individual representing a model, return a real model. If no parameters are given return a default model

if(~exist('individual','var') || isempty(individual))
  
  sm = s.smoothingBounds(1) + ((s.smoothingBounds(2) - s.smoothingBounds(1)) / 2);
  m = SplineModel(sm);

elseif(isa(individual,'Model'))
  
  m = individual;

else
  
  m = SplineModel(individual);

end
