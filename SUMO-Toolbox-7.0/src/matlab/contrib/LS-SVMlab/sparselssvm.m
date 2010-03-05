function [pmodel,nb,errest] = sparselssvm(model,tradeoff, step)
% Remove iteratively the least relevant support vectors in order to obtain sparsity
% 
% >> selector = sparselssvm({X,Y,type,gam, sig2}, tradeoff, step) 
% >> model    = sparselssvm(model,                tradeoff, step)
% 
% In each iteration step (by default 5%) of the support values
% are set to zero until the performance becomes less than tradeoff
% procent (default 75%) of the original performance.
% 
% 
%  Full syntax
% 
%     1. Using the functional interface:
% 
% >> [selector, errest] = sparselssvm({X,Y,type,gam, sig2,kernel,preprocess})
% >> [selector, errest] = sparselssvm({X,Y,type,gam, sig2,kernel,preprocess}, cutoff)
% >> [selector, errest] = sparselssvm({X,Y,type,gam, sig2,kernel,preprocess}, cutoff, step)
% 
%       Outputs    
%         selector N x 1 vector of index of chosen support vectors
%         errest(*) Estimated cost on all training data after pruning
%       Inputs    
%         X             : N x d matrix with the inputs of the training data
%         Y             : N x 1 vector with the outputs of the training data
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         cutoff(*)     : Cutoff between the validation of the original to the pruned LS-SVM
%         step(*)       : Number of the pruned support vectors in each iteration step
% 
%     2. Using the object oriented interface:
% 
% >> [model, errest] = sparselssvm(model)
% >> [model, errest] = sparselssvm(model, cutoff)
% >> [model, errest] = sparselssvm(model, cutoff, step)
% 
%       Outputs    
%         model     : Pruned object oriented representation of the LS-SVM model
%         errest(*) : Estimated cost on all training data after pruning
%       Inputs    
%         model     : Object oriented representation of the LS-SVM model
%         cutoff(*) : Cutoff between the validation of the original to the pruned LS-SVM
%         step(*)   : Number of the pruned support vectors in each iteration step
% 
% See also:
%   trainlssvm, tunelssvm, robustlssvm, crossvalidate
		    
% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab



% 
% default
%
eval('tradeoff;','tradeoff=.75;')
eval('step;','step=.05;')
eval('estfct;','estfct=''validate'';');
errest(1)=0;
t=1;
if iscell(model), functional=1; else functional=0; end


%
% initial cost
%
pmodel = trainlssvm(model);
if pmodel.y_dim>1, error('Only possible for one dimensional output models'); end
[Xt,Yt] = postlssvm(model,model.xtrain, model.ytrain);
ierrest = validate(pmodel,Xt,Yt,Xt,Yt);
selector = 1:pmodel.nb_data;


%
% loop
%
while and(errest(t)*tradeoff<=ierrest,pmodel.nb_data>5), 
  
  %
  % prune
  % 

  [spectr,spectri] = sort(abs(pmodel.alpha));
  spectri = spectri(max(3,floor(length(spectri)*step)):end);
  pmodel = changelssvm(pmodel,'selector',pmodel.selector(spectri)); 
  
  %
  % re-estimate performance
  %
  pmodel.alpha =[];
  %pmodel = trainlssvm(pmodel);
  [errest(t+1),pmodel] = validate(pmodel,Xt(pmodel.selector,:),Yt(pmodel.selector,:),Xt,Yt);
  t= t+1;


end

%plot(errest)

if functional
  pmodel = pmodel.selector;
end