function s = setSamples(s,smp,val)

% setSamples (SUMO)
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
%	s = setSamples(s,smp,val)
%
% Description:
%	Set the samples/values currently available in the modelbuilder

%set on all contained model interfaces
for i=1:length(s.modelInterfaces)
	mi = s.modelInterfaces{i};
	mi = mi.setSamples(smp,val);
	s.modelInterfaces{i} = mi;
end

s = s.setSamples@GeneticFactory(smp,val);
