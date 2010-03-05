function fcns = buildTransferFcnList(tfunctionTemplate, dimension);

% buildTransferFcnList (SUMO)
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
%	fcns = buildTransferFcnList(tTemplate, dimension);
%
% Description:
%	    tfunctions is a list of allowed transfer functions.  It contains max 2 entries:
%	the first entry gives the transfer function for all hidden layers, the second entry gives
%	the function for the output layer.
%	This function returns the full transfer function list for a given network architecture.

% no hidden layers
if(length(dimension) == 2)
	fcns = cell(1,1);
	fcns{1} = tfunctionTemplate{end};
% at least one hidden layer
else
	fcns = cell(1,length(dimension)-2);
	for(i=1:length(dimension)-2)
		fcns{i} = tfunctionTemplate{1};
	end
	i = i + 1;
	fcns{i} = tfunctionTemplate{2};
end
