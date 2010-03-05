function [eigval, eigvec, scores, omega] = kpca(Xtrain, kernel_type, kernel_pars ,Xt,etype,n,centr)
% Kernel Principal Component Analysis (KPCA)
% 
% >> [eigval, eigvec] = kpca(X, kernel_fct, sig2)
% >> [eigval, eigvec, scores] = kpca(X, kernel_fct, sig2, Xt)
% 
% Compute the nb largest eigenvalues and the corresponding rescaled
% eigenvectors corresponding with the principal components in the
% feature space of the centered kernel matrix. To calculate the
% eigenvalue decomposition of this N x N matrix, Matlab's
% eig is called by default. The decomposition can also be
% approximated by Matlab ('eigs') or by Nyström's method ('eign')
% using nb components. In some cases one wants to disable
% ('original') the rescaling of the principal components in feature
% space to unit length. 
% 
% The scores of a test set Xt on the principal components is computed by the call:
% 
% >> [eigval, eigvec, scores] = kpca(X, kernel_fct, sig2, Xt)
% 
% Full syntax
% 
% >> [eigval, eigvec, empty, omega] = kpca(X, kernel_fct, sig2) 
% >> [eigval, eigvec, empty, omega] = kpca(X, kernel_fct, sig2, [],etype, nb) 
% >> [eigval, eigvec, empty, omega] = kpca(X, kernel_fct, sig2, [],etype, nb, rescaling) 
% >> [eigval, eigvec, scores, omega] = kpca(X, kernel_fct, sig2, Xt) 
% >> [eigval, eigvec, scores, omega] = kpca(X, kernel_fct, sig2, Xt,etype, nb) 
% >> [eigval, eigvec, scores, omega] = kpca(X, kernel_fct, sig2, Xt,etype, nb, rescaling)
% 
% Outputs    
%   eigval       : N (nb) x 1 vector with eigenvalues values
%   eigvec       : N x N (N x nb) matrix with the principal directions
%   Xt(*)        : Nt x nb matrix with the scores of the test data (or [])
%   Omega(*)     : N x N centered kernel matrix
% Inputs    
%   X            : N x d matrix with the inputs of the training data
%   kernel       : Kernel type (e.g. 'RBF_kernel')
%   sig2         : Kernel parameter(s) (for linear kernel, use [])
%   Xt(*)        : Nt x d matrix with the inputs of the test data (or [])
%   etype(*)     : 'svd', 'eig'(*),'eigs','eign'
%   nb(*)        : Number of eigenvalues/eigenvectors used in the eigenvalue decomposition approximation
%   rescaling(*) : 'original size' ('o') or 'rescaling'(*) ('r')
% 
% See also:
%   bay_lssvm, bay_optimize, eign

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% defaults 
%
nb_data = size(Xtrain,1);
eval('n=min(n,nb_data);','n=min(10,nb_data);')
eval('centr;','centr=''rescaled'';');
eval('etype;','etype=''eig'';');
eval('Xt;','Xt=[];');


%
% tests
%
if ~isempty(Xt) & size(Xt,2)~=size(Xtrain,2),
  error('Training points and test points need to have the same dimension');
end

if ~(strcmpi(etype,'svd') | strcmpi(etype,'eig') | strcmpi(etype,'eigs') | strcmpi(etype,'eign')),
  error('Eigenvalue decomposition via ''svd'', ''eig'', ''eigs'' or ''eign''...');
end


if (strcmpi(etype,'svd') | strcmpi(etype,'eig') | strcmpi(etype,'eigs')),
  
  omega = kernel_matrix(Xtrain,kernel_type, kernel_pars);
  

  % centered kernel matrix : Z*omega*Z
  %Zc = eye(nb_data) - ones(nb_data)./nb_data;
  %omega = Zc*omega*Zc;
  Meanvec = mean(omega);
  MM = mean(Meanvec);
  for i=1:nb_data,
    omega(i,:) = omega(i,:)-Meanvec(i);
  end
  for i=1:nb_data,
    omega(:,i) = omega(:,i)-Meanvec(i);
  end
  omega = omega+MM;
  
  
  %
  % eigenvalues are computed with more stable svd
  %
  
  % numerical stability issues
  omega = (omega+omega')./2;
  
  if strcmpi(etype,'svd'),
    [eigvec, eigval,ff] = svd(omega); clear ff
  elseif strcmpi(etype,'eig'),
    [eigvec, eigval] = eig(omega); 
  elseif (strcmpi(etype,'eigs')),
    [eigvec, eigval] = eigs(omega,n);
  end
  eigval = diag(eigval)./(nb_data-1);



elseif strcmpi(etype,'eign'),
  if nargout>1,
    [eigvec,eigval] = eign(Xtrain,kernel_type,kernel_pars, n); 
  else
    eigval = eign(Xtrain,kernel_type,kernel_pars, n); 
  end
  omega = [];
  eigval = (eigval)./(nb_data-1);
  Meanvec = [];
  MM = [];


else
  error('Unknown type for eigenvalue approximation');
end

%
% only keep relevant eigvals & eigvec
%
peff = find(eigval>1000*eps);
%eigval = eigval(peff);
neff = length(peff);
%if nargout>1, eigvec = eigvec(:,peff); end

% rescaling the eigenvectors
if (centr(1) =='r' & nargout>1),
  %disp('rescaling the eigvec');
  for i=1:neff,
    eigvec(:,i) = eigvec(:,i)./sqrt(eigvec(:,i)'*eigval(i)*eigvec(:,i));
  end
end


%
% compute scores
%
if ~isempty(Xt),
  omega_t = kernel_matrix(Xtrain,kernel_type, kernel_pars,Xt);

  if isempty(Meanvec),
    if size(omega_t,2)>10,  Meanvec = mean(omega_t,2); MM = mean(Meanvec); end
  end
  for i=1:size(omega_t,1),
    omega_t(i,:) = omega_t(i,:)-Meanvec(i);
  end
  for i=1:size(omega_t,2),
    omega_t(:,i) = omega_t(:,i)-Meanvec(i);
  end
  omega_t = omega_t+MM;    
  scores = omega_t'*eigvec;
else
  scores = [];
end




