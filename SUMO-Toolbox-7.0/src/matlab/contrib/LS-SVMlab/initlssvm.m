function model = initlssvm(X,Y,type, gam, sig2, kernel_type, preprocess, implementation,cgashow)
% Initiate the object oriented structure representing the LS-SVM model
%
%   model = initlssvm(X,Y, type, gam, sig2)
%   model = initlssvm(X,Y, type, gam, sig2, kernel_type)
%   model = initlssvm(X,Y, type, gam, sig2, kernel_type, implementation)
%
% Full syntax
% 
% >> model = initlssvm(X, Y, type, gam, sig2, kernel, preprocess)
% 
%       Outputs    
%         model         : Object oriented representation of the LS-SVM model
%       Inputs    
%         X             : N x d matrix with the inputs of the training data
%         Y             : N x 1 vector with the outputs of the training data
%         type          : 'function estimation' ('f') or 'classifier' ('c')
%         gam           : Regularization parameter
%         sig2          : Kernel parameter (bandwidth in the case of the 'RBF_kernel')
%         kernel(*)     : Kernel type (by default 'RBF_kernel')
%         preprocess(*) : 'preprocess'(*) or 'original'
%         implementation(*): 'CMEX' (*), 'CFILE' or 'MATLAB'
% 
%
% see also:
%   trainlssvm, simlssvm, changelssvm, codelssvm, prelssvm

% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab



% check enough arguments?
if nargin<5,
  error('Not enough arguments to initialize model..');
elseif ~isnumeric(sig2),
  error(['Kernel parameter ''sig2'' needs to be a (array of) reals' ...
	 ' or the empty matrix..']); 
end

%
% CHECK TYPE
%
if type(1)~='f', if type(1)~='c', if type(1)~='t', if type(1)~='N', 
      error(['type has to be ''function (estimation)'', ''classification'', ''timeserie'' or ''NARX'''] );
end;end;end;end;
model.type = type;

%
% choice of implementation: 'MATLAB', 'MATLAB', 'MATLAB' 
%
eval('model.implementation=implementation;','model.implementation=''CMEX'';');
%model.implementation='MATLAB';
%model.implementation='CFILE';

%
% check datapoints
%
model.x_dim = size(X,2);
model.y_dim = size(Y,2);

if and(type(1)~='t',and(size(X,1)~=size(Y,1),size(X,2)~=0)), error(['number of datapoints not equal to number of targetpoints...']); end  
model.nb_data = size(X,1);
%if size(X,1)<size(X,2), warning('less datapoints than dimension of a datapoint ?'); end
%if size(Y,1)<size(Y,2), warning('less targetpoints than dimension of a targetpoint ?'); end
if isempty(Y), error('empty datapoint vector...'); end


%
% using preprocessing {'preprocess','original'}
%
eval('preprocess; model.preprocess=preprocess;','model.preprocess=''preprocess'';');
if model.preprocess(1) == 'p', 
  model.prestatus='changed';
else model.prestatus='ok'; end

%
% initiate datapoint selector
%
model.xtrain = X;
model.ytrain = Y;
model.selector=1:model.nb_data;



%
% regularisation term and kenel parameters
%
if(gam<=0) error('gam must be larger then 0');end
model.gam = gam;


% kernel type: for MATLAB implementation the function <kernel>.m
% must do the job. In MATLAB and MATLAB, the implementation of the
% kernels is in c-src/kernels.h and c-src/kernels.c
%
% initializing kernel type
%
eval('model.kernel_type = kernel_type;','model.kernel_type = ''RBF_kernel'';');
% kernel parameters (i.c. RBF:sigma^2) 
if sig2<=0,
  model.kernel_pars = (model.x_dim);
else
  model.kernel_pars = sig2;
end

%
% cga options; only used if C implementation is used
%
model.cga_max_itr = model.nb_data;
model.cga_eps = 1e-15;
model.cga_fi_bound = 1e-15;
eval('model.cga_show = cgashow;','model.cga_show = 0;');

%
% dynamic models
%
model.x_delays = 0;
model.y_delays = 0;
model.steps = 1;


% for classification: one is interested in the latent variables or
% in the class labels
model.latent = 'no';
model.duration = 0;

% coding type used for classification
model.code = 'original';
eval('codetype;model.codetype=codetype;',...
     'model.codetype =''none'';');

% preprocessing step
model = prelssvm(model);

% to be called after right initialization
%model = codelssvm(model);


% status of the model: 'changed' or 'trained'
model.status = 'changed';

