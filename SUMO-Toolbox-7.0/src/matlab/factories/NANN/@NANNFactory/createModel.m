function m = createModel(s,individual);

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
%	m = createModel(s,individual);
%
% Description:
%	Given an individual representing a model, return a real model

[ni no] = getDimensions(s);

if(~exist('individual','var') || isempty(individual))
  
  dim = [ni s.initialSize no];
  dim = dim(dim > 0);

  m = NANNModel(dim,s.epochs,s.trainingGoal);
  m = setPruneTechnique(m, s.allowedPruneTechniques(1));

elseif(isa(individual,'Model'))
  
  m = individual;

else

  dim = [ni individual no];
  dim = dim(dim > 0);

  m = NANNModel(dim,s.epochs,s.trainingGoal);
  m = setPruneTechnique(m, s.allowedPruneTechniques(1));

end
