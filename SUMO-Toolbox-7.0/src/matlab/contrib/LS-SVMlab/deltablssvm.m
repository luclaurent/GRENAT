function model = deltablssvm(model,a1,a2)
% Bias term correction for the LS-SVM classifier
% 
% >> model = deltablssvm(model, b_new)
% 
% This function is only useful in the object oriented function
% interface. Set explicitly the bias term b_new of the LS-SVM model.
% 
% Full syntax
% 
% >> model = deltablssvm(model, b_new)
% 
% Outputs    
%   model : Object oriented representation of the LS-SVM model with initial hyperparameters
% Inputs    
%   model : Object oriented representation of the LS-SVM model
%   b_new : m x 1 vector with new bias term(s) for the model
% 
% See also:
%   roc, trainlssvm, simlssvm, changelssvm

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab

if iscell(model),
  model = initlssvm(model{:});
end

if iscell(a1),
  model.alpha = a1{1};
  model.b = a1{2};
  model.status = 'trained';
  deltab = a2;
else
  deltab = a1;
end

if ~(model.type(1)=='c' & model.y_dim==1),
  error('only for binary classification tasks');
end


% without retraining
model.b = deltab;function model = deltablssvm(model,a1,a2)
% Set the bias of the binary classification model
%
% When training the LS-SVM in a standard way, no prior information
% is incorporated. There exists however techniques who can
% calculate a bias term according to another criterium. This
% function allows to set the corrected bias in the final LS-SVM model. 
%
%   model = deltablssvm(model,newbias)
%   model = deltablssvm({X,Y,'classification',gam,sig2},{alpha,b},newbias)
%
% see also:
%   roc, changelssvm

% copyright

if iscell(model),
  model = initlssvm(model{:});
end

if iscell(a1),
  model.alpha = a1{1};
  model.b = a1{2};
  model.status = 'trained';
  deltab = a2;
else
  deltab = a1;
end

if ~(model.type(1)=='c' & model.y_dim==1),
  error('only for binary classification tasks');
end


% without retraining
model.b = deltab;