function s = constructLSSVM( s, samples, values )

% constructLSSVM (SUMO)
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
%	s = constructLSSVM( s, samples, values )
%
% Description:
%	Build a model through the samples

kp = s.config.kernelParams;
rp = 10^(s.config.regularizationParam);
kernel = '';

if (strcmp(s.config.kernel,'rbf'))
	kernel = 'RBF_kernel';
	kp = 10^kp;
elseif(strcmp(s.config.kernel,'lin'))
	kernel = 'lin_kernel';
	kp = [];
elseif(strcmp(s.config.kernel,'poly'))
	kernel = 'poly_kernel';
	% fix t to 1
	kp = [1 kp];
elseif(strcmp(s.config.kernel,'sig'))
	kernel = 'MLP_kernel';
    % fix t to 1
    kp = [kp 1];
else
	msg = sprintf('Invalid lssvm kernel type: %s',s.config.kernel);
	error(msg);
end

if(strcmp(s.getMode(),'classification'))
	% classify
	md = 'c';
elseif(strcmp(s.getMode(),'regression'))
	% function approximation
	md = 'f';
else
	error('Invalid mode, must be classification or regression');
end

s.svm = trainlssvm({samples,values,md,rp,kp,kernel,'original'});
