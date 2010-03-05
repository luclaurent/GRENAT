function [cost,costs,output] = leaveoneout(model, X,Y, estfct,combinefct, corrected,trainfct,simfct)
% Estimate the performance of a trained model with leave-one-out crossvalidation
% 
% >> leaveoneout({X,Y,type,gam,sig2}, Xval, Yval)
% >> leaveoneout(model, Xval, Yval)
% 
% In each iteration, one leaves one point, and fits a model on the
% other data points. The performance of the model is estimated
% based on the point left out. This procedure is repeated for each
% data point. Finally, all the different estimates of the
% performance are combined (default by computing the mean). The
% assumption is made that the input data is distributed independent
% and identically over the input space. A statistical bias
% reduction technique can be applied.
% 
% By default, this function will call the training (trainlssvm) and
% simulation (simlssvm) algorithms for LS-SVMs. However, one can
% use the validation function more generically by specifying the
% appropriate training and simulation function.
% 
%
% Full syntax
% 
%     1. Using the functional interface for the LS-SVMs:
% 
% >> [cost, costs, el] = leaveoneout({X,Y,type,gam,sig2,kernel,preprocess}, Xval, Yval)
% >> [cost, costs, el] = leaveoneout({X,Y,type,gam,sig2,kernel,preprocess}, Xval, Yval, estfct)
% >> [cost, costs, el] = leaveoneout({X,Y,type,gam,sig2,kernel,preprocess}, Xval, Yval, estfct, combinefct)
% >> [cost, costs, el] = leaveoneout({X,Y,type,gam,sig2,kernel,preprocess}, Xval, Yval, estfct, combinefct, correction)
% 
%       Outputs    
%         cost          : Cost estimated by leave-one-out crossvalidation
%         costs(*)      : N x 1 vector with the costs of the N folds
%         el(*)         : N x 1 vector with the leave-one-out residuals
%       Inputs    
%         X             : Training input data used for defining the LS-SVM and the preprocessing
%         Y             : Training output data used for defining the LS-SVM and the preprocessing
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         Xval          : N x d matrix with the inputs of the data used for leave-one-out cross-validation
%         Yval          : N x m matrix with the outputs of the data used for leave-one-out cross-validation
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
% 
%
%     2. Using the object oriented interface for the LS-SVMs:
% 
% >> [cost, costs, el] = leaveoneout(model, Xval, Yval)
% >> [cost, costs, el] = leaveoneout(model, Xval, Yval, estfct)
% >> [cost, costs, el] = leaveoneout(model, Xval, Yval, estfct, combinefct)
% >> [cost, costs, el] = leaveoneout(model, Xval, Yval, estfct, combinefct, correction)
% 
%       Outputs    
%         cost          : Cost estimated by leave-one-out crossvalidation
%         costs(*)      : N x 1 vector with costs estimated on the N different folds
%         el(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the model
%         Xval          : Nt x d matrix with the inputs of the validation points used
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
% 
%
%     3. Using other modeling techniques:
% 
% >> [cost, costs, el] = leaveoneout(model, Xval, Yval, estfct, combinefct, correction, trainfct, simfct)
% 
%       Outputs    
%         cost          : Cost estimated by leave-one-out crossvalidation
%         costs(*)      : N x 1 vector with costs estimated on the N different folds
%         el(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the model
%         Xval          : Nt x d matrix with the inputs of the validation points used
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
%         trainfct      : Function used to train the model
%         simfct        : Function used to simulate test data with the model
% 
% See also:
%   leaveoneout_lssvm, validate, crossvalidate, trainlssvm, simlssvm

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% initialisation and defaults
%
eval('estfct;','estfct=''mserr'';');
eval('combinefct;','combinefct=''mean'';');
eval('trainfct;','trainfct=''trainlssvm'';');
eval('simfct;','simfct=''simlssvm'';');
eval('corrected;','corrected=''original'';');

[cost,costs,output] = crossvalidate(model,X,Y,size(X,1),estfct,combinefct,corrected,trainfct,simfct);
