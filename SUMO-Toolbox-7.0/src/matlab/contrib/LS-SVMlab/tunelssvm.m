function [model,cost,O3] = tunelssvm(model,startvalues, varargin);
% Tune the hyperparameters of the model with respect to the given performance measure
%
% 1. Using the functional interface:
%
%
% >> [gam, sig2, cost] = tunelssvm({X,Y,type,igam,isig2,kernel,preprocess})
% >> [gam, sig2, cost] = tunelssvm({X,Y,type,igam,isig2,kernel,preprocess}, StartingValues)
% >> [gam, sig2, cost] = tunelssvm({X,Y,type,igam,isig2,kernel,preprocess},...
%                                          StartingValues, optfun, optargs)
% >> [gam, sig2, cost] = tunelssvm({X,Y,type,igam,isig2,kernel,preprocess},...
%                                          StartingValues, optfun, optargs, costfun, costargs)
%
%      Outputs    
%        gam     : Optimal regularization parameter
%        sig2    : Optimal kernel parameter(s)
%        cost(*) : Estimated cost of the optimal hyperparameters
%      Inputs    
%        X       : N x d matrix with the inputs of the training data
%        Y       : N x 1 vector with the outputs of the training data
%        type    : 'function estimation' ('f') or 'classifier' ('c')
%        igam    : Starting value of the regularization parameter
%        isig2   : Starting value of the kernel parameter(s) (bandwidth in the case of the 'RBF_kernel')
%        kernel(*) : Kernel type (by default 'RBF_kernel')
%        preprocess(*) : 'preprocess'(*) or 'original'
%        StartingValues(*) : Starting values of the optimization routine (or '[]')
%        optfun(*) : Optimization function (by default 'gridsearch')
%        optargs(*) : Cell with extra optimization function arguments
%        costfun(*) : Function estimating the cost-criterion (by default 'crossvalidate')
%        costargs(*) : Cell with extra cost function arguments
%
% 2. Using the object oriented interface:
%
% >> [model, cost] = tunelssvm(model)
% >> [model, cost] = tunelssvm(model, StartingValues)
% >> [model, cost] = tunelssvm(model, StartingValues, optfun, optargs)
% >> [model, cost] = tunelssvm(model, StartingValues, optfun, optargs, costfun, costargs)
%
%      Outputs    
%        model            : Object oriented representation of the LS-SVM model with optimal hyperparameters
%        cost(*)          : Estimated cost of the optimal hyperparameters
%      Inputs    
%        model            : Object oriented representation of the LS-SVM model with initial hyperparameters
%        StartingValues(*): Starting values of the optimization routine (or '[]')
%        optfun(*)        : Optimization function (by default 'gridsearch')
%        optfun(*)        : Cell with extra optimization function arguments
%        costfun(*)       : Function estimating the cost-criterion (by default 'crossvalidate')
%        optfun(*)        : Cell with extra cost function arguments
%
%  See also:
%    trainlssvm, crossvalidate, validate, gridsearch, linesearch


  
% Copyright (c) 2002,  KULeuven-ESAT-SCD, License & help @ http://www.esat.kuleuven.ac.be/sista/lssvmlab


    
%
% starting values
%
try,
  if ~isnumeric(startvalues),
    warning('Startingvalues has to be in a matrix');
  end
catch
end
  
%
% initiate variables
%
if iscell(model),
  model = initlssvm(model{:});
  func=1;
else
  func=0;
end
model = trainlssvm(model);



%
% defaults
%
if length(varargin)>=1, optfun  = varargin{1}; else optfun='gridsearch';end
if length(varargin)>=2, optargs = varargin{2}; else optargs = {}; end
if length(varargin)>=3, 
  costfun = varargin{3}; 
  if length(varargin)>=4, costargs = varargin{4}; 
  else 
    costargs ={}; 
    if strcmp(costfun,'crossvalidate') | strcmp(costfun,'rcrossvalidate') |strcmp(costfun,'leaveoneout'),
      eval('[X,Y]=postlssvm(model,model.xtrain, codelssvm(model,model.ytrain));costargs = {X,Y};',...
           '[X,Y]=postlssvm(model,model.xtrain, model.ytrain);costargs = {X,Y};')

    end
  end
else 
  costfun= 'crossvalidate'; 
  eval('[X,Y]=postlssvm(model,model.xtrain, codelssvm(model,model.ytrain));costargs = {X,Y};',...
       '[X,Y]=postlssvm(model,model.xtrain, model.ytrain);costargs = {X,Y};')
end






%
% multiple outputs
if (model.y_dim>1)% & (size(model.kernel_pars,1)==model.y_dim |size(model.gam,1)==model.y_dim |prod(size(model.kernel_type,1))==model.y_dim))
  disp(' -->> tune individual outputs');
  for d=1:model.y_dim,
    fprintf(['\n -> dim ' num2str(d) ': \n']);
    eval('gam = model.gam(:,d);','gam = model.gam;');
    eval('sig2 = model.kernel_pars(:,d);','sig2 = model.kernel_pars;');
    eval('kernel = model.kernel_type{d};','kernel=model.kernel_type;');
    [g,s,c] = ...
        tunelssvm({model.xtrain,model.ytrain(:,d),...
                   model.type,gam,sig2,kernel,'original'},...
                  [],varargin{:});
    gamt(:,d) = g;
    eval('kernel_part(:,d) = s;','kernel_part = []; ');
    costs(d) = c;
  end
  model.gam = gamt;
  model.kernel_pars = kernel_part;
  if func,
    O3 = costs;
    cost = model.kernel_pars;
    model = model.gam;
  end
  return  
end


if length(model.gam)>1, 
  error('Only one gamma per output allowed'); 
end



%
% depending on kernel
%

%
% lineare kernel
%
if strcmp(model.kernel_type,'lin_kernel'),

  optfun = 'linesearch';
  disp(' TUNELSSVM: chosen specifications:');
  disp([' 1. optimization routine:           ' optfun]);
  disp(['    cost function:                  ' costfun]);
  disp(' ');
  eval('startvalues = log(startvalues);','startvalues = [];');
  if isempty(startvalues),
    startvalues = log(model.gam)+[-5;10];
  end
  
  tic;
  c = costofmodel1(startvalues(1),model,costfun,costargs);
  et = toc; 
  disp([' 2. starting values:                   ' num2str(exp(startvalues(1,:)))]);
  disp(['    cost of starting values:           ' num2str(c)]);
  disp(['    time needed for 1 evaluation (sec):' num2str(et)]);
  disp(['    limits of the grid:   [gam]         ' num2str(exp(startvalues(:,1))')]);
  disp(' ');
  disp('OPTIMIZATION IN LOG SCALE...');
  
  %
  % major call
  [gs, cost,evals, fig] = feval(optfun, @costofmodel1,startvalues,{model, costfun,costargs},optargs{:});
  if(fig > 0), figure(fig);end
  xlabel('log(gamma)');
  ylabel(costfun);
  
  gamma = exp(gs(1));
  kernel_pars = [];
  disp(['Obtained hyper-parameters: [gamma]: ' num2str([gamma])]);


%
% RBF kernel
%
elseif strcmp(model.kernel_type,'RBF_kernel'),
  
  
  disp(' TUNELSSVM: chosen specifications:');
  disp([' 1. optimization routine:           ' optfun]);
  disp(['    cost function:                  ' costfun]);
  disp(' ');  
  eval('startvalues = log(startvalues);','startvalues = [];');
  if isempty(startvalues),
    startvalues = [log(model.gam)+[-3;5] log(model.kernel_pars)+[-2.5;2.5]];
  end
  
  tic;
  c = costofmodel2(startvalues(1,:),model,costfun,costargs);
  et = toc; 
  disp([' 2. starting values:                   ' num2str(exp(startvalues(1,:)))]);
  disp(['    cost of starting values:           ' num2str(c)]);
  disp(['    time needed for 1 evaluation (sec):' num2str(et)]);
  disp(['    limits of the grid:   [gam]         ' num2str(exp(startvalues(:,1))')]);
  disp(['                          [sig2]        ' num2str(exp(startvalues(:,2))')]);
  disp(' ');
  disp('OPTIMIZATION IN LOG SCALE...');
  [gs, cost, evals, fig] = feval(optfun,@costofmodel2,startvalues,{model, costfun,costargs},optargs{:});
  
  if(fig > 0), figure(fig);end
  xlabel('log(\gamma)');
  ylabel('log(\sigma^2)');
  zlabel(costfun);
  gamma = exp(gs(1));
  kernel_pars = exp(gs(2:end))';  
  
  
  disp(['Obtained hyper-parameters: [gamma sig2]: ' num2str([gamma kernel_pars])]);
  
  
%
% polynoom kernel
%
elseif strcmp(model.kernel_type,'poly_kernel'),

  dg = model.kernel_pars(2);
  disp(' TUNELSSVM: chosen specifications:');
  disp([' 1. optimization routine:           ' optfun]);
  disp(['    cost function:                  ' costfun]);
  disp(' ');  
  eval('startvalues = log(startvalues);','startvalues = [];');
  if isempty(startvalues),
    startvalues = [log(model.gam)+[-3;5] log(model.kernel_pars(1))+[-2.5;2.5]];
  end
  
  tic;
  c = costofmodel3(startvalues(1,:),dg,model,costfun,costargs);
  et = toc; 
  disp([' 2. starting values:                   ' num2str([exp(startvalues(1,:)) dg])]);
  disp(['    cost of starting values:           ' num2str(c)]);
  disp(['    time needed for 1 evaluation (sec):' num2str(et)]);
  disp(['    limits of the grid:   [gam]         ' num2str(exp(startvalues(:,1))')]);
  disp(['                          [t]           ' num2str(exp(startvalues(:,2))')]);
  disp(['                          [degree]      ' num2str(dg)]);
  disp('OPTIMIZATION IN LOG SCALE...');
  [gs, cost, evals, fig] = feval(optfun,@costofmodel3,startvalues,{dg,model, costfun,costargs},optargs{:});

  if(fig > 0), figure(fig);end
  xlabel('log(\gamma)');
  ylabel('log(t)');
  zlabel(costfun);
  
  gamma = exp(gs(1));
  kernel_pars = [exp(gs(2:end));dg];
  
  disp(['Obtained hyper-parameters: [gamma t degree]: ' num2str([gamma kernel_pars'])]);

else
  warning('Tuning for other kernels is not actively supported,  see ''gridsearch'' and ''linesearch''.')
end
model.cga_startvalues = [];



if func,
  O3 = cost;
  eval('cost = [kernel_pars;degree];','cost = kernel_pars;');
  model = gamma;
else
  model = changelssvm(changelssvm(model,'gam',exp(gs(1))),'kernel_pars',exp(gs(2:end)));
end



function cost =  costofmodel1(gs, model,costfun,costargs)
  gam = exp(min(max(gs(1),-50),50));
  modelf = changelssvm(model,'gam',gam);
  cost = feval(costfun,modelf,costargs{:});

  
function cost =  costofmodel2(gs, model,costfun,costargs)
  gam = exp(min(max(gs(1),-50),50));
  sig2 = zeros(length(gs)-1,1);
  for i=1:length(gs)-1, sig2(i,1) = exp(min(max(gs(1+i),-50),50)); end
  modelf = changelssvm(changelssvm(model,'gam',gam),'kernel_pars',sig2);
  cost = feval(costfun,modelf,costargs{:});

  
function cost =  costofmodel3(gs,d, model,costfun,costargs)
  gam = exp(min(max(gs(1),-50),50));
  sig2 = exp(min(max(gs(2),-50),50));
  modelf = changelssvm(changelssvm(model,'gam',gam),'kernel_pars',[sig2;d]);
  cost = feval(costfun,modelf,costargs{:});
