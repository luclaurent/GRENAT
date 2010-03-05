function this = setBounds(this, LB, UB)

% setBounds (SUMO)
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
%	this = setBounds(this, LB, UB)
%
% Description:
%	Sets bounds for optimizers that need it

if(this.getInputDimension() ~= length(LB))
  error(sprintf('The size of the lower bounds (%d) does not match the expected size of the input dimension (%d)',length(LB),this.getInputDimension()));
end
if(this.getInputDimension() ~= length(UB))
  error(sprintf('The size of the upper bounds (%d) does not match the expected size of the input dimension  (%d)',length(UB),this.getInputDimension()));
end

this.LB = LB;
this.UB = UB;

