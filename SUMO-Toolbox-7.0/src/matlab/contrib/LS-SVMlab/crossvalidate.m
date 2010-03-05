function [cost,costs,output] = crossvalidate(model, X,Y, L, estfct,combinefct, corrected,trainfct,simfct)
% Estimate the model performance of a model with [$ l$] -fold crossvalidation
%
% >> cost = crossvalidate({Xtrain,Ytrain,type,gam,sig2}, Xval, Yval)
% >> cost = crossvalidate( model, Xval, Yval)
% 
% The data is once permutated randomly, then it is divided into L
% (by default 10) disjunct sets. In the i-th (i=1,...,l) iteration,
% the i-th set is used to estimate the performance ('validation
% set') of the model trained on the other l-1 sets ('training
% set'). At last, the l (denoted by L) different estimates of the
% performance are combined (by default by the 'mean'). The
% assumption is made that the input data are distributed
% independent and identically over the input space. As additional
% output, the costs in the different folds ('costs') and all
% residuals ('ec') of the data are returned:
% 
% >> [cost, costs, ec] = crossvalidate(model, Xval, Yval)
% 
% By default, this function will call the training (trainlssvm) and
% simulation (simlssvm) algorithms for LS-SVMs. However, one can
% use the validation function more generically by specifying the
% appropriate training and simulation function. Some commonly used criteria are:
% 
% >> cost = crossvalidate(model, Xval, Yval, 10, 'misclass', 'mean', 'corrected')
% >> cost = crossvalidate(model, Xval, Yval, 10, 'mse', 'mean', 'original')
% >> cost = crossvalidate(model, Xval, Yval, 10, 'mae', 'median', 'corrected')
% 
% Full syntax
% 
%     1. Using LS-SVMlab with the functional interface:
% 
% >> [cost, costs, ec] = crossvalidate({X,Y,type,gam,sig2,kernel,preprocess},Xval, Yval, L, estfct, combinefct, correction)
% 
%       Outputs    
%         cost          : Cost estimation of the L-fold cross validation
%         costs(*)      : L x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         X             : Training input data used for defining the LS-SVM and the preprocessing
%         Y             : Training output data used for defining the LS-SVM and the preprocessing
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         Xval          : N x d matrix with the inputs of the data used for cross-validation
%         Yval          : N x m matrix with the outputs of the data used for cross-validation
%         L(*)          : Number of folds (by default 10)
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
% 
%
%     2. Using the object oriented interface:
% 
% >> [cost, costs, ec] = crossvalidate(model, Xval, Yval, L, estfct, combinefct, correction)
% 
%       Outputs    
%         cost          : Cost estimation of the L-fold cross validation
%         costs(*)      : L x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the LS-SVM model
%         Xval          : Nt x d matrix with the inputs of the validation points used in the procedure
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         L(*)          : Number of folds (by default 10)
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
% 
%
%     3. Using other modeling techniques::
% 
% >> [cost, costs, ec] = crossvalidate(model, Xval, Yval, L, estfct, combinefct, correction, trainfct, simfct)
% 
%       Outputs    
%         cost          : Cost estimation of the L-fold cross validation
%         costs(*)      : l x 1 vector with costs estimated on the L different folds
%         ec(*)         : N x 1 vector with residuals of all data
%       Inputs    
%         model         : Object oriented representation of the model
%         Xval          : Nt x d matrix with the inputs of the validation points used
%         Yval          : Nt x m matrix with the outputs of the validation points used in the procedure
%         L(*)          : Number of folds (by default 10)
%         estfct(*)     : Function estimating the cost based on the residuals (by default mse)
%         combinefct(*) : Function combining the estimated costs on the different folds (by default mean)
%         correction(*) : 'original'(*) or 'corrected'
%         trainfct      : Function used to train the model
%         simfct        : Function used to simulate test data with the model
% 
% See also:
% validate, leaveoneout, leaveoneout_lssvm, trainlssvm, simlssvm


% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


%
% initialisation and defaults
%
if size(X,1)~=size(Y,1), error('X and Y have different number of datapoints'); end
[nb_data,y_dim] = size(Y);

% LS-SVMlab
eval('model = initlssvm(model{:});',' ');


eval('L;','L=min(ceil(model.nb_data/4),10);');
eval('estfct;','estfct=''mse'';');
eval('combinefct;','combinefct=''mean'';');
eval('trainfct;','trainfct=''trainlssvm'';');
eval('simfct;','simfct=''simlssvm'';');
eval('corrected;','corrected=''original'';');


%
% make a random permutation of the data
%
px = zeros(size(X));
py = zeros(size(Y));
if L==nb_data, p = 1:nb_data; else p = randperm(nb_data); end
for i=1:nb_data,
  px(i,:) = X(p(i),:);
  py(i,:) = Y(p(i),:);
end;



block_size = floor(nb_data/L);

%
%initialize: no incremental  memory allocation
%
err = zeros(L,1);
corr2 = zeros(L,1);
costs = zeros(L,1);
output = zeros(size(Y));

%
%
% start loop over l validations
%
for l = 1:L,
  
  % divide in data and validation set, trainings data set is a copy
  % of permutated_data, validation set is just a logical index 
  if l==L,
    train = [1:block_size*(l-1)];
    validation = block_size*(l-1)+1:nb_data;
  else
    train = [1:block_size*(l-1) block_size*l+1:nb_data];
    validation = block_size*(l-1)+1:block_size*l;
  end
  
  % lets invert this...eXtreme cv
  %validation = [1:block_size*(l-1) block_size*l+1:nb_data];
  %train = block_size*(l-1)+1:block_size*l;
  %disp([num2str(l) ': |trainset|' num2str(length(train)) ' & |test| ' num2str(length(validation))]);
    
  %costs(l) = validate(model, px(train,:), py(train,:), px(validation,:), py(validation,:),estfct, trainfct, simfct);
  [costs(l), modell,output(p(validation),:)] = ...
      validate(model, px(train,:), py(train,:), px(validation,:), py(validation,:),estfct, trainfct, simfct);

  
  %
  % calculate correction term 2: MSE(f_data, error_wholedata)
  % try to reuse the previously calculated model
  %
  if corrected(1) =='c',
    eval('errors = feval(simfct, modell, px) - py;corr2(l) = feval(estfct, errors);',...
	 'corr2(l) = validate(model, px(train,:), py(train,:), px, py,estfct, trainfct, simfct);');
  end

end 


% end loop over l validations
%


%
% misclassifications
%
sc = find(costs~=inf & costs~=NaN);
ff=zeros(size(costs)); ff(sc)=costs(sc);costs=ff;
sc = find(corr2~=inf & corr2~=NaN);
ff=zeros(size(corr2)); ff(sc)=corr2(sc);corr2=ff;


%
% calculate the final costs
%
if corrected(1)=='c',
  % calculate correction term 1: MSE(f_wholedata, error_wholedata)
  corr1 = validate(model,X, Y,  X, Y,  estfct, trainfct, simfct);
  if corr1==inf | corr2==NaN, corr1=0; end
  cost = feval(combinefct, costs)+corr1-feval(combinefct,corr2);
else
  cost = feval(combinefct, costs);
end;

	  
fprintf('\n');

	
%file = [num2str(cost) '_costsLSSVM_{' num2str(model.gam(1)) ',' num2str(model.kernel_pars(1)) '}.mat'];
%save L1costs costs;