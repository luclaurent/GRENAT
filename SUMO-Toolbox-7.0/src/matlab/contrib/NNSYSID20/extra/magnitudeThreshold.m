function [NetDef, W1, W2, pr]=...
                             magnitudeThreshold(NetDef,W1,W2,PHI,Y,threshold)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function implemented based on and using the NNSYSID toolbox
%Created for use with the SUMO Toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----------------------------------------------------------------------------------
%--------------             NETWORK INITIALIZATIONS                   -------------
%----------------------------------------------------------------------------------
%more off
[outputs,N] = size(Y);                  % # of outputs and # of data
[hidden,inputs] = size(W1);             % # of hidden units 
inputs=inputs-1;                        % # of inputs
L_hidden = find(NetDef(1,:)=='L')';     % Location of linear hidden neurons
H_hidden = find(NetDef(1,:)=='H')';     % Location of tanh hidden neuron
L_output = find(NetDef(2,:)=='L')';     % Location of linear output neurons
H_output = find(NetDef(2,:)=='H')';     % Location of tanh output neurons
y1       = zeros(hidden,N);             % Hidden layer outputs
y2       = zeros(outputs,N);            % Network output
index = outputs*(hidden+1) + 1 + [0:hidden-1]*(inputs+1); % A usefull vector!
index2 = (0:N-1)*outputs;               % Yet another usefull vector
PHI_aug  = [PHI;ones(1,N)];             % Augment PHI with a row containg ones
parameters1= hidden*(inputs+1);         % # of input-to-hidden weights
parameters2= outputs*(hidden+1);        % # of hidden-to-output weights
parameters = parameters1 + parameters2; % Total # of weights
ones_h   = ones(hidden+1,1);            % A vector of ones
ones_i   = ones(inputs+1,1);            % Another vector of ones
                                        % Parameter vector containing all weights
theta = [reshape(W2',parameters2,1) ; reshape(W1',parameters1,1)];
theta_index = find(theta);              % Index to weights<>0
theta_red = theta(theta_index);         % Reduced parameter vector
reduced  = length(theta_index);         % The # of parameters in theta_red


  nElements = length(theta_red);
  IndexIDs = 1:nElements;
  a = threshold;
  condition = ['<' num2str(a)];
  Result = eval([abs('theta_red') condition]); 
  Result = IndexIDs(Result);
  nopruned = length(Result);                            % No of parm to prune
  zeta = theta_red;                                     % Weights <> 0
  [zeta_sorted,min_index] = sort(zeta);                 % Sort in ascending order
  theta_red(min_index(1:nopruned)) = zeros(nopruned,1); % Eliminate weights
  theta(theta_index) =theta_red;
       
  theta_index = theta_index(sort(min_index(nopruned+1:reduced)));
  theta_red = theta(theta_index);                       % Non-zero weights
  reduced  = reduced - nopruned;                        % Remaining weights
  pr = nopruned;                                   % Total # of pruned weights
  theta_data(:,reduced) = theta;                        % Store parameter vector
  %D = D0(theta_index);   
   
  % -- Put the parameters back into the weight matrices --
  W1 = reshape(theta(parameters2+1:parameters),inputs+1,hidden)';
  W2 = reshape(theta(1:parameters2),hidden+1,outputs)';
 % FirstTimeFlag=0;

%fprintf('\n\n\n  -->  Pruning session terminated  <--\n\n\n');
