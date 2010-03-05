function s = constructInModelSpace( s, samples, values )

% constructInModelSpace (SUMO)
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
%	s = constructInModelSpace( s, samples, values )
%
% Description:
%	Build a model through the samples

%Construct base class
s = s.constructInModelSpace@Model(samples, values );

if(strcmp(s.config.backend,'SVMlight'))
	s = constructSVMlight(s,samples,values);
elseif(strcmp(s.config.backend,'libSVM'))
	s = constructlibSVM(s,samples,values);
elseif(strcmp(s.config.backend,'lssvm'))
	s = constructLSSVM(s,samples,values);
else
	error('Invalid backend given, valid backends are SVMlight, libSVM and lssvm');
end
