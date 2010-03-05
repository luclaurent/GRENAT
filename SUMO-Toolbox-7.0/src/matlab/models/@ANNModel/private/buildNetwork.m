function this = buildNetwork(this);

% buildNetwork (SUMO)
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
%	this = buildNetwork(this);
%
% Description:
%	Initialize the matlab neural network object

%Set input ranges to [-1 1] for each input

dim = this.config.networkDim;

% use dummy patterns and targets
p = rand(dim(1),2);
t = rand(dim(end),2);

% set necessary fields
Si = dim(2:end-1);
TFi = this.config.transferFunctions;
BTF = this.config.learningRule;
BLF = 'learngdm';
PF = this.config.performFcn;
IPF = {'fixunknowns'};
OPF = {};
DDF = '';
		
% construct the actual network
network = newff(p,t,Si,TFi,BTF,BLF,PF,IPF,OPF,DDF);

network.trainParam.epochs = this.config.epochs;
network.trainParam.time = this.config.trainingTime;
network.trainParam.goal = this.config.trainingGoal;
network.trainParam.show = this.config.trainingProgress;
network.trainParam.showWindow = false;
network.trainParam.showConsole = 1;
network.trainParam.showCommandLine = 1;
network.trainParam.showWindow = false;
network.plotFcns = {};
	
%Initialize the network
network = init(network);

this.network = network;
