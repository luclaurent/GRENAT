function s = constructlibSVM( s, samples, values )

% constructlibSVM (SUMO)
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
%	s = constructlibSVM( s, samples, values )
%
% Description:
%	Build a model through the samples using libSVM

% Reminder:
%  Usage: svm-train [options] training_set_file [model_file]
%  options:
%  -s svm_type : set type of SVM (default 0)
%  	0 -- C-SVC
%  	1 -- nu-SVC
%  	2 -- one-class SVM
%  	3 -- epsilon-SVR
%  	4 -- nu-SVR
%  -t kernel_type : set type of kernel function (default 2)
%  	0 -- linear: u'*v
%  	1 -- polynomial: (gamma*u'*v + coef0)^degree
%  	2 -- radial basis function: exp(-gamma*|u-v|^2)
%  	3 -- sigmoid: tanh(gamma*u'*v + coef0)
%  	4 -- precomputed kernel (kernel values in training_set_file)
%  -d degree : set degree in kernel function (default 3)
%  -g gamma : set gamma in kernel function (default 1/k)
%  -r coef0 : set coef0 in kernel function (default 0)
%  -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)

%  -n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)
%  -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)

%  -e epsilon : set tolerance of termination criterion (default 0.001)

%  -m cachesize : set cache memory size in MB (default 100)
%  -h shrinking: whether to use the shrinking heuristics, 0 or 1 (default 1)
%  -b probability_estimates: whether to train an SVC or SVR model for probability estimates, 0 or 1 (default 0)
%  -wi weight: set the parameter C of class i to weight*C in C-SVC (default 1)
%  -v n: n-fold cross validation mode

if(size(values,2) > 1)
	error('The libSVM backend can not model multiple outputs together, please set combineOutputs to false');
end


%Translate the configuration into libsvm options
if(strcmp(s.getMode(),'classification'))
	if (strcmp(s.config.type,'C-SVC'))
		type = '-s 0';
    elseif (strcmp(s.config.type,'nu-SVC'))
		type = '-s 1';
	else
		msg = sprintf('Invalid SVM type for classification: %s',s.config.type);
		%s.logger.severe( msg );
		error(msg);
	end
elseif(strcmp(s.getMode(),'regression'))
	if (strcmp(s.config.type,'epsilon-SVR'))
		type = '-s 3';
	elseif(strcmp(s.config.type,'nu-SVR'))
		type = '-s 4';
	else
		msg = sprintf('Invalid SVM type for regression: %s',s.config.type);
		%s.logger.severe( msg );
		error(msg);
	end
else
	error('Invalid mode, must be classification or regression');
end

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
	kerParam = ['-g ' num2str(s.config.kernelParams)];
else
	msg = sprintf('Invalid Kernel type: %s',s.config.kernel);
	%s.logger.severe( msg );
	error(msg);
end

regParam = ['-c ' num2str(10^(s.config.regularizationParam))];
nu = ['-n ' num2str(s.config.nu)];
epsilon = ['-p ' num2str(s.config.epsilon)];
tolerance = ['-e ' num2str(s.config.stoppingTolerance)];

folds = s.config.crossvalidationFolds;
if(folds > 1)
	xval = ['-v ' num2str(folds)];
else
	xval = '';
end

options = [type ' ' ker ' ' kerParam ' ' regParam ' ' nu ' ' epsilon ' ' tolerance ' ' xval ' ' s.config.extraParams];

%sprintf('Calling svm train with options %s',options)

%Train the svm on the samples
s.svm = svmtrain(values,samples,options);
