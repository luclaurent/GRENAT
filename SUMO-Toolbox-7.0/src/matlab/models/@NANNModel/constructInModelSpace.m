function s = constructInModelSpace( s, samples, values )

% constructInModelSpace (SUMO)
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
%	s = constructInModelSpace( s, samples, values )
%
% Description:
%	Build an NANN model through the samples (= train the network)

%Construct base class
s = s.constructInModelSpace@Model(samples, values);

%Set up the network according to input and output dimensions
s1 = 'H';
s2 = 'L';
dim = getHiddenLayerDim(s);
a = size(values);
b = size(samples);

for j=2:dim
	s1 = [s1,'H'];
end

for j=2:a(2)
	s2 = [s2,'L'];
end

for j= 1:(dim - a(2))
	s2 = [s2,'-'];
end

NetDef = [s1;s2];

% Always start from the initial weights
W1 = s.config.initialWeights.W1;
W2 = s.config.initialWeights.W2;

% Get the default parameters
trparms = settrain;

% Make some ajustments (nb: always train with a small weight decay value)
trparms = settrain(trparms,'maxiter',s.config.epochs,'critmin',s.config.trainingGoal,'infolevel',0,'D', s.config.decayValue);

% Train the network with weight decay only
[W1,W2,critvec,iteration,lambda] = marq(NetDef,W1,W2,samples',values');

% Train the network with early stopping
%[NetDef, W1,W2] = earlyStopping(NetDef, W1, W2, s.config.epochs, samples',values');

%Save changes to Network
s.network.NetDef = NetDef;
s.network.W1 = W1;
s.network.W2 = W2;

%If necessary prune the network with the technique chosen in config
s = pruneNetwork(s, samples', values');
