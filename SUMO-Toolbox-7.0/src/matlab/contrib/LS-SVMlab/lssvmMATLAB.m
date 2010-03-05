function [model,H] = lssvmMATLAB(model) 
% Only for intern LS-SVMlab use;
%
% MATLAB implementation of the LS-SVM algorithm. This is slower
% than the C-mex implementation, but it is more reliable and flexible;
%
%
% This implementation is quite straightforward, based on MATLAB's
% backslash matrix division (or PCG if available) and total kernel
% matrix construction. It has some extensions towards advanced
% techniques, especially applicable on small datasets (weighed
% LS-SVM, gamma-per-datapoint)

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%fprintf('~');
%
% is it weighted LS-SVM ?
%
weighted = (length(model.gam)>model.y_dim);
if and(weighted,length(model.gam)~=model.nb_data),
  warning('not enough gamma''s for Weighted LS-SVMs, simple LS-SVM applied');
  weighted=0;
end



% --------------
% classification
% --------------
%
% no blockdiag. as described in papers. (MATLAB '\' ! ),  for
% multi-class tasks, the algorithm is multiple times executed. the
% kernel-matrix is just calculated once.
if (model.type(1)=='c'), 

  % computation omega and H 
  H = kernel_matrix(model.xtrain(model.selector, 1:model.x_dim), ...
			model.kernel_type, model.kernel_pars);
  % initiate alpha and b
  model.b = zeros(1,model.y_dim);
  model.alpha = zeros(model.nb_data,model.y_dim);
  
  for i=1:model.y_dim,
  
    for t=1:model.nb_data,for s=1:t-1,
	H(s,t) = H(s,t)*(model.ytrain(model.selector(s),i)*model.ytrain(model.selector(t),i)');
	H(t,s) = H(s,t);
    end; end
    
    if size(model.gam,2)==model.nb_data, 
      invgam = model.gam(i,:).^-1;      
      for t=1:model.nb_data, H(t,t) = H(t,t)+invgam(t); end
    else
      invgam = model.gam(i,1)^-1;
      for t=1:model.nb_data, H(t,t) = H(t,t)+invgam; end
    end
    
    nuv = H\[model.ytrain(model.selector,i) ones(model.nb_data,1)];
    %eval('nuv = pcg(H,[model.ytrain(model.selector,i) ones(model.nb_data,1)],100*eps,model.nb_data);','nuv = H\[model.ytrain(model.selector,i) ones(model.nb_data,1)];');
   
    nu(:,i) = nuv(:,1);
    v(:,i) = nuv(:,2);

    
    s(i) = model.ytrain(model.selector,i)'*nu(:,i);
    model.b(i) = (nu(:,i)'*ones(model.nb_data,1))/s(i);
    model.alpha(:,i) = v(:,i)-(nu(:,1)*model.b(i));
  end
  
  return 

else
% ---------------------
%  function estimation  
% ---------------------

  % computation omega and H 
  omega = kernel_matrix(model.xtrain(model.selector, 1:model.x_dim), ...
			model.kernel_type, model.kernel_pars);
  

  % initiate alpha and b
  model.b = zeros(1,model.y_dim);
  model.alpha = zeros(model.nb_data,model.y_dim);

  for i=1:model.y_dim,

    H = omega;
    % computation matrix omega = K(x_i,x_j)*1/gamma
    if size(model.gam,2)==model.nb_data, 
      eval('invgam = model.gam(i,:).^-1;','invgam = model.gam(1,:).^-1;');
      for t=1:model.nb_data, H(t,t) = H(t,t)+invgam(t); end
    else
      eval('invgam = model.gam(i,1).^-1;','invgam = model.gam(1,1).^-1;');
      for t=1:model.nb_data, H(t,t) = H(t,t)+invgam; end
    end 
    
    v = H\model.ytrain(model.selector,i); 
    %eval('v  = pcg(H,model.ytrain(model.selector,i), 100*eps,model.nb_data);','v = H\model.ytrain(model.selector, i);');
    nu = H\ones(model.nb_data,1);
    %eval('nu = pcg(H,ones(model.nb_data,i), 100*eps,model.nb_data);','nu = H\ones(model.nb_data,i);');
    s = ones(1,model.nb_data)*nu(:,1);
    model.b(i) = (nu(:,1)'*model.ytrain(model.selector,i))./s;  
    model.alpha(1:model.nb_data,i) = v(:,1)-(nu(:,1)*model.b(i));
  end
  return   

end



