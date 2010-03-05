function [costs, z, yh, model] = leaveoneout_lssvm(model,gams, estfct)
% Fast leave-one-out cross-validation for the LS-SVM based on one full matrix inversion
% 
% >> cost = leaveoneout_lssvm({X,Y,type,gam,sig2})
% >> cost = leaveoneout_lssvm(model              )
% 
% This implementation is based on the matrix inversion lemma. Based
% on one global kernel matrix inversion, one can compute
% simultaneously all folds. One can evaluate simultaneously the
% leave-one-out error for a number of regularization parameters by
% passing them as an vector.
% 
% >> costs = leaveoneout_lssvm(model, [gam1, gam2, ...])
% 
% A different estimation function can be used (the default is mse),
% e.g. the mean absolute error:
% 
% >> costs = leaveoneout_lssvm(model, [], 'mae')
% 
% Full syntax
%   (The number of different regularization parameters is denoted by g.)
%
% 
%     1. Using the functional interface:
% 
% >> [cost, el, Yl] = leaveoneout_lssvm({X,Y,type,[],sig2,kernel,preprocess})
% >> [cost, el, Yl] = leaveoneout_lssvm({X,Y,type,[],sig2,kernel,preprocess}, gams)
% >> [cost, el, Yl] = leaveoneout_lssvm({X,Y,type,[],sig2,kernel,preprocess}, gams, estfct)
% 
%       Outputs    
%         cost  : g x 1 vector with leave-one-out cost estimations
%                 corresponding with the number of passed regularization parameters.
%         el(*) : N x g matrix with the residuals of g different regularization parameters
%         Yl(*) : N x g matrix with the estimated (latent) outputs of
%                 the training data corresponding with the g different regularization parameters
%       Inputs    
%         X             : Training input data used for defining the LS-SVM and the preprocessing
%         Y             : Training output data used for defining the LS-SVM and the preprocessing
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         gams          : g x 1 vector with different regularization parameters one wants to evaluate
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
% 
%
%     2. Using the object oriented interface:
% 
% >> [cost, el, Yl, model] = leaveoneout_lssvm(model)
% >> [cost, el, Yl, model] = leaveoneout_lssvm(model, gams)
% >> [cost, el, Yl, model] = leaveoneout_lssvm(model, gams, estfct)
% 
%       Outputs    
%         cost      : g x 1 vector with different regularization parmeters
%         el(*)     : N x g matrix with the residuals corresponding with the g different regularization parmeters
%         Yl(*)     : N x g matrix with the estimated (latent)
%                     outputs of the training data corresponding with the g different regularization parameters
%         model(*)  : Trained object oriented representation of the model
%       Inputs    
%         model     : Object oriented representation of the model
%         gams(*)   : Different regularization parameters one wants to evaluate
%         estfct(*) : Function estimating the cost based on the residuals (by default mse)
% 
% See also:
%   leaveoneout, crossvalidate, trainlssvm


% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab

% initialize alpha's and b
if iscell(model),
  model = initlssvm(model{:});
end
if model.type(1)=='c',
  model.type = 'function estimation';
  class = 1;
else
  class = 0;
end

eval('gams;','gams = model.gam;');
if isempty(gams), 
  gams = model.gam; 
end
if isempty(model.gam),
  eval('model.gam = gams(1);','error(''no regularization parameters are passed...'');');
elseif length(model.gam)>1,
  model = changelssvm(model,'gam',model.gam(1));
end

model = trainlssvm(model);
[X,Y] = postlssvm(model,model.xtrain, model.ytrain);

%if model.type(1)~='f' | model.y_dim~=1,
%  warning('only available for one dimensional function estimation');
%end

if model.y_dim~=1,
  warning('only for 1-dimensional output predictions');
end

% estimation function is by default 'mse'
eval('estfct;','estfct=''mserr'';');


% kernel matrix computation
K = kernel_matrix(model.xtrain,model.kernel_type,model.kernel_pars);



for g = 1:length(gams),

  % global initialization dependent of gams(g)
  Ka = [K+eye(model.nb_data)./gams(g) ones(model.nb_data,1);...
	ones(1,model.nb_data) 0];
  invKa = pinv(Ka);

  
  % loop over N folds
  for i=1:model.nb_data,
    sel = [1:i-1 i+1:model.nb_data];
    alphab = [model.alpha(sel);model.b] - (model.alpha(i)/invKa(i,i)).*invKa([sel end],i);
    yh(i,g) = alphab(1:end-1,1)'*K(sel,i)+alphab(end); 
  end
  if class, 
    if model.preprocess(1)=='p',
      [ff,yhp(:,g)] = postlssvm(model,[],yh(:,g));
    else
      yhp(:,g) = sign(yh(:,g)-eps);
    end
    z(:,g) = yhp(:,g)~=Y;
    eval('costs(g) = feval(estfct,yhp(:,g),Y);',...
	 'costs(g) = feval(estfct,yhp(:,g)-Y);')
    model.type = 'classifier';
  else
    [ff,yh(:,g)] = postlssvm(model,[],yh(:,g));
    z(:,g) = yh(:,g)-Y;
    eval('costs(g) = feval(estfct,yh(:,g),Y);', 'costs(g) = feval(estfct,yh(:,g)-Y);')
  end

end
