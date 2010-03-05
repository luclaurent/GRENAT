function this = setDimensions(this,inDim,outDim)

% setDimensions (SUMO)
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
%	this = setDimensions(this,inDim,outDim)
%
% Description:
%	Sets the number of input and output dimensions (= number of objectives)

this.nvars = inDim;
this.nobjectives = outDim;

% update bounds/initpoint
if(length(this.LB) ~= this.nvars)
	this.LB = -ones( 1, this.nvars );
end

if(length(this.UB) ~= this.nvars)
	this.UB = ones( 1, this.nvars );
end

if(size(this.initialPopulation,2) ~= this.nvars)
	this.initialPopulation = zeros( this.getPopulationSize(), this.nvars );
end
