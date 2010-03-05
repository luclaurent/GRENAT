function [psi dpsi] = correlationMatrix(this, theta, lambda)

% correlationMatrix (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	[psi dpsi] = correlationMatrix(this, theta, lambda)
%
% Description:
%	Generate correlation matrix of the samples
%	Parameters: theta: Level 1 parameter (to be optimized)
%	ModelInfo: Level 2 parameters (fixed)

  n = size(this.values, 1);
  lambda = 10.^lambda;
  o = (1:n)';
  
  % Fast calculation of correlation matrix
  if nargout > 1
    [psi dummy dtheta] = feval(this.correlationFcn, theta, this.dist);
    
    dpsi = cell(1,size(dtheta,2));
    parfor i=1:length(dpsi)
        idx = find(dtheta(:,i) ~= 0);
        dpsi{i} = sparse([this.distIdxPsi(idx,1); o], [this.distIdxPsi(idx,2); o], [dtheta(idx,i); zeros(n,1)]);
    end
    
    % derivative to lambda
    if ~isinf(this.options.lambda0)
        dpsi{end+1} = sparse( o, o, (lambda.*log(10))./2 );
    end
    
  else
    psi = this.correlationFcn( theta, this.dist );
  end
  
  % Create sparse correlation matrix
  idx = find(psi > 0);
  psi = sparse([this.distIdxPsi(idx,1); o], [this.distIdxPsi(idx,2); o], [psi(idx); ones(n,1)+lambda]);
  
end
