function res = complexity(model);

% complexity (SUMO)
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
%	res = complexity(model);
%
% Description:
%	Returns the number of free variables in the model.

kernel = model.config.kernel;

% 1 for the kernel type
res = 1;

if (strcmp(kernel,'lin'))
	res = res + 0;
elseif (strcmp(kernel,'rbf'))
	%The rbf spread
	res = res + 1;
elseif (strcmp(kernel,'poly'))
	%The degree
	res = res + 1;
elseif (strcmp(kernel,'sig'))
	%The slope
	res = res + 1;
else
	error('Invalid SVM kernel type specified');
end

%Add the number of support vectors used
if(strcmp(model.config.backend,'libSVM'))
	svs = model.svm.sv_coef;
elseif(strcmp(model.config.backend,'SVMlight'))
	svs = model.svm.sv_num;
elseif(strcmp(model.config.backend,'lssvm'))
	svs = model.svm.alpha;
else
	error(sprintf('Invalid backend %d given',s.backend));
end

res = res + length(svs(svs > 0));
