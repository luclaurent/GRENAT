function [] = saveToDisk(s, outputDirectory)

% saveToDisk (SUMO)
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
%	[] = saveToDisk(s, outputDirectory)
%
% Description:
%	Store succesful & failed samples to disk.

% save unfiltered samples
header = ['% This file contains all the samples evaluated in this run. Each line contains the input values for one sample followed by outputs.' 10];
saveDataToDisk(s, fullfile(outputDirectory,'samples.txt'), header, s.samplesUnfiltered, s.valuesUnfiltered);

% save failed samples
header = ['% This file contains all the samples that failed to evaluate in this run. Each line contains the input values for one sample followed by outputs.' 10];
saveDataToDisk(s, fullfile(outputDirectory,'samplesFailed.txt'), header, s.failedSamplesUnfiltered, s.failedValuesUnfiltered, s.failedReasons);
