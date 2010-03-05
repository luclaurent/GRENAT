function [measureData numTargets] = setupMeasures(this,config)

% setupMeasures (SUMO)
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
%	[measureData numTargets] = setupMeasures(this,config)
%
% Description:
%	Instantiate and configure the Measure objects that will be used to drive this model builder

import java.util.logging.*
import ibbt.sumo.profiler.*;
import ibbt.sumo.config.*;

% initiate as empty data structures
measureItems = {};

% we are going to take a measure centric view
% however, it is also convenient to have an index
% that has a output centric view.  Thus we maintain
% a cell array that remembers which measureItem index
% belongs to which output
outputCentricIndex = cell(1,this.outputDimension);
for i=1:this.outputDimension
    outputCentricIndex{i} = {};
end

% for each output processed by this model builder we have a set of measures

% WARNING: if you change the order of adding measures you must update
% processBestModel and setModelInfo as well !!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First treat the measures that were defined for all outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

globalMeasures = this.outputDesc(1).getGlobalMeasures();

for i = 0 : globalMeasures.size()-1;
    measure = instantiate(globalMeasures.get(i), config);
    
    % save the measure item
    measureItem.measure = measure;
    measureItem.outputCoverage = 1:this.outputDimension;
    measureItem.profilers = {};
    
    measureItems = [measureItems measureItem];
    
    for j=1:this.outputDimension
        outputCentricIndex{j} = [outputCentricIndex{j} length(measureItems)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now see if specific outputs were configured with specific measures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1 : this.outputDimension
    
    % get base measures (root nodes) from config, init data structures
    localMeasures = this.outputDesc(i).getLocalMeasures();
    
    % walk all measures, set up targets
    for j=0:localMeasures.size()-1
        measure = instantiate(localMeasures.get(j), config);
        
        % save the measure item
        measureItem.measure = measure;
        measureItem.outputCoverage = i;
        measureItem.profilers = {};
        
        measureItems = [measureItems measureItem];
        
        outputCentricIndex{i} = [outputCentricIndex{i} length(measureItems)];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now setup the associated data structures and profilers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

targets = [];
weights = [];

for i=1:length(measureItems)
    mi = measureItems{i};
    oc = mi.outputCoverage;
    measure = mi.measure;
    
    if(measure.isEnabled())
        % the same target/weight is used for each output covered by the measure
        measureTargets = repmat(measure.getTarget(),1,length(oc));
        measureWeights = repmat(measure.getWeight(),1,length(oc));
    
        % add tot the total list of targets
        targets = [targets measureTargets];
        weights = [weights measureWeights];
    else
        % disabled measures are ignored
    end
    
    % this measure may cover more than one output
    % make sure we add a separate profiler for each output covered
    measureProfilers = {};
    
    for j = 1 : length(oc)
        
        o = oc(j);
        
        if(measure.isEnabled())
            profname = ['Measure_' this.outputNames{o} '_' class(measure) '_' func2str(getErrorFcn(measure))];
        else
            profname = ['Measure_' this.outputNames{o} '_' class(measure) '_' func2str(getErrorFcn(measure)) '_off'];
        end
        
        %if a profiler with this id already exists, add a numeric suffix
        profname = ProfilerManager.makeUniqueProfilerName(profname);
        measureProfiler = ProfilerManager.getProfiler(profname);  
        measureProfiler.setDescription([class(measure) ' score on ' this.outputNames{o} '; using ' func2str(getErrorFcn(measure)) '']);

        if this.samplingEnabled
            %adaptive sampling switched on
            measureProfiler.addColumn('sampleSize', 'Number of samples');
        else
            %only adaptive modeling
            measureProfiler.addColumn('iteration', 'New best model number');
        end
        
        measureProfiler.addColumn('score', [class(measure) ' score using ' func2str(getErrorFcn(measure)) ', target is ' num2str(measure.getTarget())]);
        measureProfilers = [measureProfilers {measureProfiler}];
    end
    
    mi.profilers = measureProfilers;
    measureItems{i} = mi;
end

numTargets = length(targets);

% generate an error if no measures at all were added
if numTargets < 1
    msg = 'You must specify at least one measure to be used for evaluation';
    this.logger.severe(msg);
    error(msg);
end

measureData = struct();
measureData.finalTargets = targets;
%normalize weights
measureData.weights = weights ./ sum(weights);
measureData.measures = measureItems;
measureData.outputCentricIndex = outputCentricIndex;

