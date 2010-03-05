function [points items] = samplesWithHighError(model, relative, n, varargin)

% samplesWithHighError (SUMO)
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
%	[points items] = samplesWithHighError(model, relative, n, varargin)
%
% Description:
%	Given a model, returns for each output the n samples with the highest error
%
%	[points items] = samplesWithHighError(model, relative, n, [samples], [values] )
%
%	model: the model to evaluate
%	relative: true -> relative error , false -> absolute error
%	n: the number of points to return
%	samples, values : use these samples/values instead of the model ones
%
%	points: a cell array with one entry for each output.  Each entry contains a matrix with
%	        the following columns: sample points, model prediction, true values, error
%
%	items: the same information as above only now in struct form for
%	convenience

if(~exist('relative','var'))
    relative = true;
end

if(~exist('n','var'))
    n = 20;
end

if(nargin < 1)
    error('Must pass a model object');
elseif(nargin <= 3)
    samples = model.getSamples();
    values = model.getValues();
elseif(nargin == 5)
    samples = varargin{1};
    values = varargin{2};
else
    error('Invalid number of arguments given');
end


% calculate the model prediction on the samples
prediction = model.evaluate(samples);

% calculate the error
if(relative)
    err = relativeError(values,prediction);
else
    err = absoluteError(values,prediction);
end

% sort
[B I] = sort(err,1,'descend');

% get the points with the n largest errors
points = {};
item = struct();
items = {};

for i=1:size(err,2)
    
    item.output = i;
    item.samples = samples(I(1:n,i),:);
    item.predicted = prediction(I(1:n,i),i);
    item.true = values(I(1:n,i),i);
    item.errors = err(I(1:n,i),i);
    
    points = [points ; [samples(I(1:n,i),:) prediction(I(1:n,i),i) values(I(1:n,i),i) err(I(1:n,i),i)]];
    items = [items item];
end
