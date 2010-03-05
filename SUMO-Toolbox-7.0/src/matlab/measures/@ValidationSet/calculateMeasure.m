function [m, newModel, score] = calculateMeasure(m, model, context, outputIndex)

% calculateMeasure (SUMO)
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
%	[m, newModel, score] = calculateMeasure(m, model, context, outputIndex)
%
% Description:
%	Splits the list of samples in a set of validation samples and a
%	set of training samples. Then a new model is constructed using the
%	training samples, and the accuracy of this model is validationed using
%	the validation samples. When an external dataset is provided, the entire list
%	of samples is used for training and the model is evaluated against
%	the dataset.
%	The model that was constructed is returned, so that sub-measures can
%	act on this model.

% get validation samples in case of dataset
if strcmp(m.set, 'file')
	validationSamples = m.validationSamples;
	validationValues = m.validationValues;
	newModel = model;

% get validation samples/values in case of subset of provided samples
else
	% get samples
	samples = getSamplesInModelSpace(model);
	values = getValues(model);
	
	% update the validation set
	m = calculateValidationSet(m, samples);
	
	% separate validation samples from real samples
	validationSamples = samples(m.validationSamples,:);
	validationValues = values(m.validationSamples,:);
	
	% delete the validation samples from the real samples
	samples(m.validationSamples,:) = [];
	values(m.validationSamples,:) = [];

	% construct is needed after all....	
	%Only needed if this measure has sub measures
	%if(hasSubMeasures(m))
		% produce a new model based on the remaining samples
		newModel = constructInModelSpace(model, samples, values);
	%else
	%	newModel = model;
	%end
end

% number of validation samples
nValidationSamples = size(validationSamples,1);

% score the model against the validation samples
producedValues = evaluateInModelSpace(newModel, validationSamples);

% filter out the correct output
producedValues = producedValues(:,outputIndex);
validationValues = validationValues(:,outputIndex);
score = feval(getErrorFcn(m), validationValues, producedValues);

% produce additional analysis data
%  abs_error = abs(producedValues - validationValues);
%  rel_error = abs_error ./ ( 1 + abs(validationValues) );
%  relmax_error = abs_error ./ max( abs(validationValues) );
%  
%  msg = ['Additional error measures on the validationset: ' ...,
%  	sprintf( '\n\t- Max Absolute error: %d', max(abs_error) ),...
%  	sprintf( '\n\t- Max Relative error: %d', max(rel_error) ),...
%  	sprintf( '\n\t- Max RelativeMax error: %d', max(relmax_error) ),...
%  	sprintf( '\n' ),...
%  	sprintf( '\n\t- RMS Absolute error: %d', rms(abs_error) ),...
%  	sprintf( '\n\t- RMS Relative error: %d', rms(rel_error) ),...
%  	sprintf( '\n\t- RMS RelativeMax error: %d', rms(relmax_error) )];
%  
%  m.logger.finer(msg);
