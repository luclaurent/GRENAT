function [total_data] = groupModelData(directory, runMask );

% groupModelData (SUMO)
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
%	[total_data] = groupModelData(directory, runMask );
%
% Description:
%	Groups all best models in one cell array

if(~exist('runMask'))
	runMask = '.*';
end

% Collect all profilers in the given directory
runNames = dir([directory '/' runMask]);

data = struct();
total_data = [];

for r=1:length(runNames)
    if runNames(r).isdir
        % get the run name
        runName = runNames(r).name;

        % get the location of samples.txt
        samplesFile = fullfile(directory,runName,'samples.txt');

        data.samples = load( samplesFile );

        modelFile = dir( fullfile(directory,runName,'best/*.mat' ) );
        load( fullfile(directory,runName,'best/',modelFile.name) );
        data.bestModel = model;
        
        total_data = [total_data data];
    end
end
