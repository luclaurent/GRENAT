function [coste, costse, costs] = rcrossvalidate(model, X,Y, L, times, estfct,combinefct, trainfct,simfct)
% Estimate the model performance with robust L-fold crossvalidation
% 
% >> cost = rcrossvalidate({X,Y,'function',gam,sig2}, X,Y)
% >> cost = rcrossvalidate(model, X,Y)
% 
% Robustness in the L-fold crossvalidation score function is
% obtained by using a trimmed mean of the squared residuals in the
% individual error estimates and by repeating the crossvalidation
% over different partitions of the data. 
% 
% This routine is very computational intensive.
% 
% By default, this function will call the training (robustlssvm)
% and simulation (simlssvm) algorithms for LS-SVMs. However, one
% can use the validation function more generically by specifying
% the appropriate training and simulation function. 
% 
% Full syntax
% 
%     * Using LS-SVMlab with the functional interface:
% 
% >> [cost, costs, ec] = rcrossvalidate({X,Y,type,gam,sig2,kernel, preprocess},Xval, Yval)
% >> [cost, costs, ec] = rcrossvalidate({X,Y,type,gam,sig2,kernel, preprocess},Xval, Yval, L)
% >> [cost, costs, ec] = rcrossvalidate({X,Y,type,gam,sig2,kernel, preprocess},Xval, Yval, L, times)
% >> [cost, costs, ec] = rcrossvalidate({X,Y,type,gam,sig2,kernel, preprocess},Xval, Yval, L, times, estfct, combinefct)
% 
%       Outputs    
%         cost          : Cost estimation of the robust L-fold cross-validation
%         costs(*)      : L x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         X             : N x d matrix with training input data used for defining the LS-SVM and the preprocessing
%         Y             : N x m matrix with training output data used for defining the LS-SVM and the preprocessing
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter(s) (for linear kernel, use |[]|)
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         Xval          : N x d matrix with the inputs of the data used for cross-validation
%         Yval          : N x m matrix with the outputs of the data used for cross-validation
%         L(*)          : Number of folds (by default 10)
%         times(*)      : Number of times the data is distributed over the L folds
%         estfct(*)     : Function estimating the cost based on the residuals (by default trimmedmse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
% 
%
%     * Using the object oriented interface:
% 
% >> [cost, costs, ec] = rcrossvalidate(model, Xval, Yval)
% >> [cost, costs, ec] = rcrossvalidate(model, Xval, Yval, L)
% >> [cost, costs, ec] = rcrossvalidate(model, Xval, Yval, L, times)
% >> [cost, costs, ec] = rcrossvalidate(model, Xval, Yval, L, times, estfct, combinefct)
% 
%       Outputs    
%         cost          : Cost estimation of the robust L-fold cross-validation
%         costs(*)      : L x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the LS-SVM model
%         Xval          : Nt x d matrix with the inputs of the validation points used in the procedure
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         L(*)          : Number of folds (by default 10)
%         times(*)      : Number of times the data is distributed over the L folds
%         estfct(*)     : Function estimating the cost based on the residuals (by default trimmedmse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
% 
%  
%     * Using other modeling techniques:
%   
% >> [cost, costs, ec] = rcrossvalidate(model, Xval, Yval, L, times, estfct, combinefct, trainfct, simfct)
% 
%       Outputs    
%         cost          : Cost estimation of the robust L-fold cross-validation
%         costs(*)      : l x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the model
%         Xval          : Nt x d matrix with the inputs of the validation points used
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         L(*)          : Number of folds (by default 10)
%         times(*)      : Number of times the data is distributed over the L folds
%         estfct(*)     : Function estimating the cost based on the residuals (by default trimmedmse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         trainfct      : Function used to train robustly the model
%         simfct        : Function used to simulate test data with the model
% 
% See also:
%  trimmedmse, crossvalidate, validate, trainlssvm, robustlssvm

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab

eval('times;','times=10;');
eval('L;','L=10;');
eval('estfct;','estfct=''trimmedmse'';');
eval('combinefct;','combinefct=''mean'';');
eval('trainfct;','trainfct=''robustlssvm'';');
eval('simfct;','simfct=''simlssvm'';');
estfct='trimmedmse';

for t=1:times,
  [costse(t),costs(:,t)] = ...
      crossvalidate(model, X,Y, L, estfct,combinefct,0,trainfct,simfct);
end
coste = mean(costse);

