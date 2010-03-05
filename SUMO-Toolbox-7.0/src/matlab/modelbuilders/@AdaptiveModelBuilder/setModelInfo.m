function model = setModelInfo(s, model, score)

% setModelInfo (SUMO)
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
%	model = setModelInfo(s, model, score)
%
% Description:
%	Set important contextual information on the model: the input names, output names, transformation values,
%	measure data, etc.  This is information only the modelbuilder has.

% set the transformation functions for the model
model = setTransformationValues(model, s.transformationValues);

% set the input and output names (used as labels in plots)
model = setInputNames(model,s.inputNames);
model = setOutputNames(model,s.outputNames);

% if the model has not been scored yet, return
if score < 0
    return
end

% save how well this model scored on the different measures
% we save a struct that contains a cell of measure details per output
% AND, for convenience, a score matrix containing the score of each measure
% on each output

% the measure details are grouped per output
measureInfo = cell(1,s.outputDimension);
for i=1:length(measureInfo)
    measureInfo{i} = {};
end

% the rows are the measures, the columns are the outputs
% the the cell (i,j) contains the score of measure i on output j
% initialize to NaNs, a NaN will mark that measure i is not applied to
% output j
scoreMatrixFull = ones(length(s.measureData.measures),length(s.outputNames))*NaN;

% go over each measure and set the respective score
% WARNING: the order of these loops is important! processBestModel depends on it!
disabledMeasures = [];

for i = 1 : length(s.measureData.measures)
    mi = s.measureData.measures{i};
    measure = mi.measure;
    oc = mi.outputCoverage;
    
    % remember which measures are disabled
    if(~measure.isEnabled())
        disabledMeasures = [disabledMeasures i];
    end
    
    for j=1:length(oc)
        % get the selected output
        o = oc(j);
        
        measureStruct = struct();
        measureStruct.type = class(measure);
        measureStruct.errorFcn = func2str(measure.getErrorFcn());
        measureStruct.enabled = measure.isEnabled();
        measureStruct.score = mi.scores(j);
        measureInfo{o} = [measureInfo{o} measureStruct];
        
        scoreMatrixFull(i,o) = mi.scores(j);
    end
    
end

% create a matrix with only the enabled measures
scoreMatrixEnabled = scoreMatrixFull;
scoreMatrixEnabled(disabledMeasures,:) = [];

mdata = struct();
mdata.measureInfo = measureInfo;
mdata.scoreMatrixFull = scoreMatrixFull;
mdata.scoreMatrixEnabled = scoreMatrixEnabled;

model = setMeasureScores(model, mdata);
model = setScore(model, score);
