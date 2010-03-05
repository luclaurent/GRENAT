function s = constructSVMlight( s, samples, values )

% constructSVMlight (SUMO)
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
%	s = constructSVMlight( s, samples, values )
%
% Description:
%	Build a model through the samples using SVMlight
%	See http://webspace.ship.edu/thbrig/mexsvm/

if (strcmp(s.config.kernel,'rbf'))
	ker = '-t 2';
	kerParam = ['-g ' num2str(10^(s.config.kernelParams))];
elseif(strcmp(s.config.kernel,'lin'))
	ker = '-t 0';
	kerParam = '';
elseif(strcmp(s.config.kernel,'poly'))
	ker = '-t 1 -r 1';
	kerParam = ['-d ' num2str(s.config.kernelParams)];
elseif(strcmp(s.config.kernel,'sig'))
	ker = '-t 3 -r 1';
	kerParam = ['-s ' num2str(s.config.kernelParams(1)) '-r' num2str(s.config.kernelParams(2))];
else
	msg = sprintf('Invalid Kernel type: %s',s.config.kernel);
	%s.logger.severe( msg );
	error(msg);
end

regParam = ['-c ' num2str(10^(s.config.regularizationParam))];
epsilon = ['-w ' num2str(s.config.epsilon)];
tolerance = ['-e ' num2str(s.config.stoppingTolerance)];

if(strcmp(s.getMode(),'classification'))
	% classify
	md = 'c';
elseif(strcmp(s.getMode(),'regression'))
	% function approximation
	md = 'r';
else
	error('Invalid mode, must be classification or regression');
end

options = ['-v 0 -z ' md ' ker ' ' kerParam ' ' regParam ' ' epsilon ' ' tolerance];

%sprintf('Calling svmlight with options %s',options)

%Train the svm on the samples
s.svm = svmlearn(samples,values,options);
