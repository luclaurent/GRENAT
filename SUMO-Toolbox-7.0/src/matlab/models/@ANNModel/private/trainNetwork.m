function s = trainNetwork(s,patterns,targets,setInitWeights)

% trainNetwork (SUMO)
%
%     This file is part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     and you can redistribute it and/or modify it under the terms of the
%     GNU Affero General Public License version 3 as published by the
%     Free Software Foundation.  With the additional provision that a commercial
%     license must be purchased if the SUMO Toolbox is used, modified, or extended
%     in a commercial setting. For details see the included LICENSE.txt file.
%     When referring to the SUMO-Toolbox please make reference to the corresponding
%     publication.
%
% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
% Revision: $Rev: 6376 $
%
% Signature:
%	s = trainNetwork(s,patterns,targets,setInitWeights)
%
% Description:
%	Trains a Neural Network on the specifed patterns and targets

% Set the network object to match the config

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WARNING: THE ORDER OF THE STATEMENTS BELOW IS IMPORTANT !!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Always train in batch mode
s.network.adaptFcn = 'trainb';	

% set the transfer functions
for i=1:length(s.network.layers)
    s.network.layers{i}.transferFcn = s.config.transferFunctions{i};
end

% set the training function
s.network.trainFcn = s.config.learningRule;
% the above call resets network.trainParam !! So set back the correct values
s.network.trainParam.epochs = s.config.epochs;
s.network.trainParam.time = s.config.trainingTime;
s.network.trainParam.goal = s.config.trainingGoal;
s.network.trainParam.show = s.config.trainingProgress;
s.network.trainParam.showConsole = 1;
s.network.trainParam.showCommandLine = 1;
s.network.trainParam.showWindow = false;

% set the performance function
s.network.performFcn = s.config.performFcn;

if(setInitWeights)
    %Set the initial weights to those specified in the config
    %This ensures deterministic training since we always start from the same
    %set of initial weights.
    s.network.IW = s.config.initialWeights.IW;
    s.network.LW = s.config.initialWeights.LW;
    s.network.b = s.config.initialWeights.b;
else
    % dont set initial weights, start from the weights of the network
end

ratios = s.config.earlyStoppingRatios;

if(strcmp(s.config.trainMethod,'auto'))
	%Train with early stopping if we are not using regularization
	if( ((strcmp(s.network.performFcn,'msereg') == 0)...
		&& (strcmp(s.network.performFcn,'mseregec') == 0)...
		&& (strcmp(s.network.trainFcn,'trainbr') == 0)) )

		% prepare for early stopping
        s.network.divideFcn = 'dividerand';
        s.network.divideParam.trainRatio = ratios(1);
        s.network.divideParam.valRatio = ratios(2);
        s.network.divideParam.testRatio = ratios(3); 
	else
		% Simply train on all data
		% randomly shuffle the samples and targets
		len = size(patterns,2);
		data = shuffleRows([patterns targets]);
		patterns = data(:,1:len);
		targets = data(:,len+1:end);
	end

elseif(strcmp(s.config.trainMethod,'earlyStopping'))
    
    s.network.divideFcn = 'dividerand';
    s.network.divideParam.trainRatio = ratios(1);
    s.network.divideParam.valRatio = ratios(2);
    s.network.divideParam.testRatio = ratios(3); 

else
	% Simply train on all data
	% randomly shuffle the samples and targets
	len = size(patterns,2);
	data = shuffleRows([patterns targets]);
	patterns = data(:,1:len);
	targets = data(:,len+1:end);
end

[s.network,tr] = train(s.network,patterns',targets');
