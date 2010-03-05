function [NetDef, W1, W2] = earlyStopping(NetDef, W1, W2, epochs, samples, values)

% earlyStopping (SUMO)
%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
%     Copyright W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene, 2005-2008
% Contact : mailto:dirk.gorissen@ugent.be
%
% Description:
%     An early stopping implementation for the NNSYSID toolbox

% build a random validation set of 20%
n = round(0.2*length(samples));
p = randperm(length(samples));

testSamples = samples(:,p(1:n));
testValues = values(:,p(1:n));

samples(:,p(1:n)) = [];
values(:,p(1:n)) = [];

trainSamples = samples;
trainValues = values;

% Train for 10 epochs
trparms = settrain;
trparms = settrain(trparms,'maxiter',10,'infolevel',0);

W3 = zeros(size(W1));
W4 = zeros(size(W2));

oldError = Inf;
newError = -Inf;

iter = 0;
while(iter < epochs)
	%Train the network
	[W3,W4,critvec,iteration,lambda] = marq(NetDef,W1,W2,trainSamples,trainValues,trparms);

	iter = iter + 10;
	
	%Calculate the validation error
	[values,E,newError] = nneval(NetDef,W3,W4,testSamples,testValues,0);

	if(newError < oldError)
        	W1 = W3;
        	W2 = W4;
        	oldError = newError;
	else
		%Validation error is starting to increase again, stop training
		%disp('stopping')
		break;
	end
end
