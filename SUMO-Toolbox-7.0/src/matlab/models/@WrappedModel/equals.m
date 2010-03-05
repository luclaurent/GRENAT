function res = equals(s,m, threshold)

% equals (SUMO)
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
%	res = equals(s,m, threshold)
%
% Description:
%	Simply call the base class method

if(~exist('threshold','var'))
	threshold = 0;
end

if(isa(m,'WrappedModel'))
	res = equals(s.nestedModel,getNestedModel(m),threshold);
else
	res = equals(s.nestedModel,m,threshold);
end
