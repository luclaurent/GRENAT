function [model,b] = robustlssvm(model,ab,X,Y) 
% Robust training in the case of non-Gaussian noise or outliers
% 
% >> [alpha, b] = robustlssvm({X,Y,type,gam,sig2,kernel})
% >> model     = robustlssvm(model)
% 
% Robustness towards outliers can be achieved by reducing the
% influence of support values corresponding to large errors.
%
% 
% Full syntax
% 
%     1. Using the functional interface:
% 
% >> [alpha, b] = robustlssvm({X,Y,type,gam,sig2}, {alpha,b})
% >> [alpha, b] = robustlssvm({X,Y,type,gam,sig2,kernel}, {alpha,b})
% >> [alpha, b] = robustlssvm({X,Y,type,gam,sig2,kernel,preprocess}, {alpha,b})
% >> [alpha, b] = robustlssvm({X,Y,type,gam,sig2,kernel,preprocess})
%
%       Outputs    
%         alpha         : N x m matrix with support values of the robust LS-SVM
%         b             : 1 x m vector with bias term(s) of the robust LS-SVM
%       Inputs    
%         X             : N x d matrix with the inputs of the training data
%         Y             : N x 1 vector with the outputs of the training data
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         alpha(*)      : Support values obtained from training
%         b(*)          : Bias term obtained from training
% 
%
%     2. Using the object oriented interface:
% 
% >> model = robustlssvm(model)
% 
%       Outputs    
%         model : Robustly trained object oriented representation of the LS-SVM model
%       Inputs    
%         model : Object oriented representation of the LS-SVM model
% 
% See also:
%   trainlssvm, tunelssvm, crossvalidate


% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab



if iscell(model),
  func = 1;
  model = initlssvm(model{:});
else
   func = 0;
end


if model.type(1)~='f',
  error('Robustly weighted least squares only implemented for regression case...');
end



if nargin>1,
  if iscell(ab) & ~isempty(ab),
    model.alpha = ab{1};
    model.b = ab{2};
    model.status = 'trained';
    if nargin>=4,
      model = trainlssvm(model,X,Y);
    end
  else
    model = trainlssvm(model,ab,X);
  end
else
  model = trainlssvm(model);
end


% defaults for c1 and c2
c1=2.5;
c2=3;

% model errors
ek = model.alpha./model.gam';

%
% robust estimation of the variance
%
%vare = iqr(ek)/1.349;
vare = 1.483*median(abs((ek)-median(ek)));

%
% robust re-estimation of the alpha's and the b
%
cases = reshape(abs(ek./vare),1,model.nb_data);
dc = c2-c1;
gam = model.gam.*(cases<=c1) + ...
      model.gam.*(cases<=c2 & cases>c1).*((c2-cases)./dc) + ...
      model.gam.*(cases>c2).*10e-4;

model = changelssvm(model,'gam',gam);
model = changelssvm(model,'implementation','MATLAB');
model = trainlssvm(model);
%figure;plot(ek,model.gam,'*');

if func & nargout~=1,
  b = model.b;
  model = model.alpha;
end