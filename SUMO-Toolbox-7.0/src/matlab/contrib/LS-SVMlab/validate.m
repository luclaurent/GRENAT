function [cost,nmodel,output] = validate(model, Xtrain, Ytrain, Xtest, Ytest,estfct, trainfct, simfct) 
% Validate a trained model on a fixed validation set
% 
% >> cost = validate({X,Y,type,gam,sig2}, Xtrain, Ytrain, Xtest, Ytest)
% 
% In the case of regression, most common is to use the mean squared
% error ('mse') as an estimate of the cost of the model. It is known
% that the trimmed mean of the squared errors ('trimmedmse') is more
% robust estimate when non-Gaussian noise or outliers occur. For
% classification, a suitable cost criterion is the rate of
% misclassification ('misclass'). 
% 
% By default, this function will call the training ('trainlssvm') and
% simulation ('simlssvm') algorithms for LS-SVMs. However, one can
% use the validation function more generically by specifying the
% appropriate training and simulation function. 
% 
%
% Full syntax
% 
%     1. Using the functional interface for the LS-SVMs:
% 
% >> cost = validate({X,Y,type,gam,sig2,kernel,preprocess}, Xtrain, Ytrain, Xtest, Ytest)
% >> cost = validate({X,Y,type,gam,sig2,kernel,preprocess}, Xtrain, Ytrain, Xtest, Ytest, estfct)
% 
%       Outputs    
%         cost          : Cost estimated by validation on test set
%       Inputs    
%         X             : Training input data used for defining the LS-SVM and the preprocessing
%         Y             : Training output data used for defining the LS-SVM and the preprocessing
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         Xtrain        : N x d matrix with the input data used for training
%         Ytrain        : N x m matrix with the output data used for training
%         Xtest         : N x d matrix with the input data used for testing
%         Ytest         : N x m matrix with the output data used for testing
%         estfct(*)     : Function estimating the cost based on the residuals (by default 'mserr')
% 
%
%     2. Using the object oriented interface for the LS-SVMs:
% 
% >> cost = validate(model, Xtrain, Ytrain, Xtest, Ytest)
% >> cost = validate(model, Xtrain, Ytrain, Xtest, Ytest, estfct)
% 
%       Outputs    
%         cost      : Cost estimated by validation on test set
%       Inputs    
%         model     : Object oriented representation of the model
%         Xtrain    : N x d matrix with the input data used for training
%         Ytrain    : N x m matrix with the output data used for training
%         Xtest     : N x d matrix with the input data used for testing
%         Ytest     : N x m matrix with the output data used for testing
%         estfct(*) : Function estimating the cost based on the residuals (by default 'mserr')
% 
%
%     3. Using other modeling techniques::
% 
% >> cost = validate(model, Xtrain, Ytrain, Xtest, Ytest, estfct, trainfct, simfct)
% 
%       Outputs    
%         cost     : Cost estimated by validation on test set
%       Inputs    
%         model    : Object oriented representation of the model
%         Xtrain   : N x d matrix with the input data used for training
%         Ytrain   : N x m matrix with the output data used for training
%         Xtest    : N x d matrix with the input data used for testing
%         Ytest    : N x m matrix with the output data used for testing
%         estfct   : Function estimating the cost based on the residuals 
%         trainfct : Function used for training model
%         simfct   : Function used for simulating model
%
%
% See also:
%   crossvalidate, leaveoneout
 
% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% defaults
%
eval('estfct;','estfct=''mserr'';');
eval('trainfct;','trainfct=''trainlssvm'';');
eval('simfct;','simfct=''simlssvm'';');
  


% LS-SVMlab
eval('model = initlssvm(model{:});',' ');

model.status = 'changed';
nmodel = feval(trainfct,model,Xtrain, Ytrain);
output = feval(simfct,nmodel,Xtest);


%
% try to train and to evaluate the model
%
%disp(['-> ' num2str(size(Xtest)) ' & ' num2str(size(output)) ' & ' num2str(size(Ytest))]);
eval(['cost = ' estfct '(output-Ytest);'],'cost = inf;')
if cost==inf, 
  eval(['cost = ' estfct '(output,Ytest);'],...
       'warning(''Error in estimator function ...'');');
end
%cost = eval('feval(estfct,output-Ytest);','feval(estfct,output,Ytest);');

