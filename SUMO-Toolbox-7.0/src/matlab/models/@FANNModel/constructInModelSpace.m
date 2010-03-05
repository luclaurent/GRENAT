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
%	Build a FANN model through the samples (= train the network)

%Construct base class
s = s.constructInModelSpace@Model(samples, values);

%Train the network on the samples using the initial weights specified in the model object
s.network.weights = s.config.initialWeights;
[s.network] = trainFann(s.network,samples,values,s.config.trainingGoal,s.config.epochs);
