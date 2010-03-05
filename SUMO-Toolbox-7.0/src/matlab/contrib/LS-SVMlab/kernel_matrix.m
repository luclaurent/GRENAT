function omega = kernel_matrix(Xtrain,kernel_type, kernel_pars,Xt)
% Construct the positive (semi-) definite and symmetric kernel matrix
% 
% >> Omega = kernel_matrix(X, kernel_fct, sig2)
% 
% This matrix should be positive definite if the kernel function
% satisfies the Mercer condition. Construct the kernel values for
% all test data points in the rows of Xt, relative to the points of X.
% 
% >> Omega_Xt = kernel_matrix(X, kernel_fct, sig2, Xt)
% 
%
% Full syntax
% 
% >> Omega = kernel_matrix(X, kernel_fct, sig2)
% >> Omega = kernel_matrix(X, kernel_fct, sig2, Xt)
% 
% Outputs    
%   Omega  : N x N (N x Nt) kernel matrix
% Inputs    
%   X      : N x d matrix with the inputs of the training data
%   kernel : Kernel type (by default 'RBF_kernel')
%   sig2   : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%   Xt(*)  : Nt x d matrix with the inputs of the test data
% 
% See also:
%  RBF_kernel, lin_kernel, kpca, trainlssvm, kentropy


% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab



nb_data = size(Xtrain,1);

if nb_data> 3000,
  error(' Too memory intensive, the kernel matrix is restricted to size 3000 x 3000 ');
end

%if size(Xtrain,1)<size(Xtrain,2),
%  warning('dimension of datapoints larger than number of datapoints?');
%end


if strcmp(kernel_type,'RBF_kernel'),
  if nargin<4,    
    XXh = sum(Xtrain.^2,2)*ones(1,nb_data);
    omega = XXh+XXh'-2*Xtrain*Xtrain';
    omega = exp(-omega./kernel_pars(1));
  else
    XXh1 = sum(Xtrain.^2,2)*ones(1,size(Xt,1));
    XXh2 = sum(Xt.^2,2)*ones(1,nb_data);
    omega = XXh1+XXh2' - 2*Xtrain*Xt';
    omega = exp(-omega./kernel_pars(1));
  end
    
else
  
  if nargin<4,
    omega = zeros(nb_data,nb_data);
    for i=1:nb_data,
      omega(i:end,i) = feval(kernel_type,  Xtrain(i,:), Xtrain(i:end,:),kernel_pars);
      omega(i,i:end) = omega(i:end,i)';
    end
    
  else
    if size(Xt,2)~=size(Xtrain,2),
      error('dimension test data not equal to dimension traindata;');
    end
    omega = zeros(nb_data, size(Xt,1));
    for i=1:size(Xt,1),
      omega(:,i) = feval(kernel_type,  Xt(i,:), Xtrain, kernel_pars);
    end
  end
end