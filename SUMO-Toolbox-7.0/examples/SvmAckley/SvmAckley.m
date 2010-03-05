function res = SvmAckley(spread,c)

% SvmAckley (SUMO)
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
%	res = SvmAckley(spread,c)
%
% Description:
%	Return the MSE of a SVM built with given c,spread on the Ackley function

%Ensure deterministic results
oldstate = rand('state');
rand('state',0);

%scale to [-7 7] and take exp
c = exp(c*7);

%scale to [-4 4] and take exp
spread = exp(spread*4);

trainSamples = rand(500,2)*2-1;
trainValues = Ackley(trainSamples);

testSamples = rand(500,2)*2-1;
testValues = Ackley(testSamples);

options = ['-s 3 -t 2 -g ' num2str(spread) ' -c ' num2str(c) ' -n 0.01 -p 0 -e 1e-05'];

%Train the svm on the samples
svm = svmtrain(trainValues,trainSamples,options);

%calculate the mse on the testset
[values, accuracy, decisionValues] = svmpredict(rand(size(testSamples,1),1),testSamples,svm,'');

res = mse(testValues-values);

%reset the state as if nothing happend
rand('state',oldstate)
