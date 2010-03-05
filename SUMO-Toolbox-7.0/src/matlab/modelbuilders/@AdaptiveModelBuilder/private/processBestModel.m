function [s] = processBestModel(s)

% processBestModel (SUMO)
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
%	[s] = processBestModel(s)
%
% Description:
%	This function takes care of plotting, logging and saving a new best
%	model.

import java.util.logging.*;
import ibbt.sumo.util.*;

% get best model & best model score
score = getBestModelScore(s);
model = s.bestModels{1};

%Get the elapsed time
t = etime(clock,s.startTime);

modelclass = class(model);

% print out basic score & description
s.logger.info(' ');
s.logger.info(sprintf('New best %s for %s',modelclass, arr2str(s.outputNames)));
s.logger.info(sprintf(' - Best model score: %d', score));
s.logger.fine(sprintf(' - Best model description: %s', getDescription(model)));
s.logger.info(sprintf(' - Elapsed time: %d min', t/60));

%Log to profilers
if s.samplingEnabled
    xaxis = size(getSamplesInModelSpace(model),1);
else
    xaxis = s.bestModelIndex;
end

s.elapsedTimeProfiler.addEntry([xaxis, t/60]);
s.bestModelProfiler.addEntry([xaxis, score]);
s.freeParamProfiler.addEntry([xaxis, complexity(model)]);
maxmem = floor(java.lang.Runtime.getRuntime.maxMemory/1024^2);
usedmem = maxmem - floor(java.lang.Runtime.getRuntime.freeMemory/1024^2);
s.resourcesProfiler.addEntry([xaxis, usedmem, maxmem - usedmem]);

% trigger the measure profilers

% first get the scores of this model on the various measures
mdata = model.getMeasureScores();
measureScores = mdata.measureInfo;

% also get a vector of enabled measure scores ordered by measure (see setupMeasures for more info)
measureScoreVector = reshape(mdata.scoreMatrixEnabled',1,numel(mdata.scoreMatrixEnabled));
% remove any NaNs (NaNs are present at location (i,j) of the
% scoreMatrix if measure i does not apply to output j
measureScoreVector(isnan(measureScoreVector)) = [];
    
% since the measure data stored in the model is a output-centric view
% we need the outputCentricIndex
% WARNING: the order of these loops is important! setModelInfo depends on
% it!
for o = 1 : length(measureScores)
    for i=1:length(measureScores{o})
        
        % get the score of the i'th measure on output o
        sc = measureScores{o}{i}.score;
        
        % get the i'th measure item that applies to output o
        idx = s.measureData.outputCentricIndex{o}{i};
        mi = s.measureData.measures{idx};
        
        % get the correct profiler from mi
        % if mi is a global measure it contains a profiler for every output
        % if mi is a local measure it only contains a single profiler
        if(length(mi.outputCoverage) > 1)
            mi.profilers{o}.addEntry([xaxis, sc]);
        else
            mi.profilers{1}.addEntry([xaxis, sc]);
        end
    end
end

% create best model dir
if (~isdir(fullfile(s.outputDirectory, 'best')))
    mkdir(s.outputDirectory, 'best');
end

%Do we have a display/keyboard/mouse available?
headless = Util.isHeadless();

% print/log/plot information about each output for the best model

for o = 1 : length(s.outputNames)
    s.logger.info(sprintf(' - Model scores for output %s:', s.outputNames{o}));
    
    for i=1:length(measureScores{o})
        measureStruct = measureScores{o}{i};
        s.logger.info(sprintf( '    * Score on measure %s (%s) : %d%s' , measureStruct.type, measureStruct.errorFcn, measureStruct.score, iff(measureStruct.enabled, '', ' (not used)' ) ));
    end
    
    % create the directory to store the models for this output
    modelDirectory = ['models_' s.outputNames{o}];
    if (~isdir(fullfile(s.outputDirectory, modelDirectory)))
        mkdir(s.outputDirectory, modelDirectory);
    end
    
    % plot model for this output
    if (s.plotOptions.plotModels)
        try
            figureHandle = plotModel(model,o,s.plotOptions);
        catch err
            figureHandle = -1;
            msg = sprintf('Problem during plotting of model: %s', err.message);
            s.logger.severe(msg);
            printStackTrace(err.stack,s.logger, Level.SEVERE);
        end
    end
    
    % save model plots if configured to do so
    if (s.plotOptions.plotModels)
        try
            if(headless)
                fileName = fullfile(s.outputDirectory, modelDirectory, sprintf('model_%04d.fig', s.bestModelIndex));
                
                %Save the model plot for the model trace
                hgsave(figureHandle, fileName);
                
                %Copy to the best directory (=faster than saving again) -> crashes in headless environments
                %copyfile(fileName, fullfile(s.outputDirectory,'best',[s.outputNames{o} '.fig']));
                hgsave(figureHandle, fullfile(s.outputDirectory,'best',[s.outputNames{o} '.fig']));
                
            else
                fileName = fullfile(s.outputDirectory, modelDirectory,sprintf('model_%04d.%s', s.bestModelIndex,s.plotOptions.outputType));
                
                %Save the model plot for the model trace
                saveas(figureHandle, fileName);
                
                %Save to the best directory, use copy since it is faster
                copyfile(fileName, fullfile(s.outputDirectory,'best',[s.outputNames{o} '.' s.plotOptions.outputType]));
                %saveas(figureHandle, fullfile(s.outputDirectory,'best',[s.outputNames{o} '.' s.plotOptions.outputType] ));
                
            end
            
            s.logger.info(sprintf('Saved plots of model to file "%s"', fileName));
        catch err
            msg = sprintf('Problem during saving plot: %s', err.message);
            s.logger.severe(msg);
            printStackTrace(err.stack,s.logger, Level.SEVERE);
        end
    end
    
    
    % store current model if configured to do so
    if s.plotOptions.saveModels
        lastModelFilename = fullfile(s.outputDirectory, modelDirectory, sprintf('model_%04d.mat', s.bestModelIndex));
        
        try
            save(lastModelFilename, 'model');
            s.logger.info(sprintf('Saved model to file "%s"', lastModelFilename));
        catch err
            msg = sprintf('Problem during saving of model file to disk: %s', err.message);
            s.logger.severe(msg);
            printStackTrace(err.stack,s.logger, Level.SEVERE);
        end
    end
end

% create best model file name
modelFileName = [ 'model[' stringJoin(s.outputNames,'_') '].mat' ];
 
% overwrite best model data
if s.plotOptions.saveModels
    try
        save(fullfile(s.outputDirectory,'best', modelFileName), 'model');
    catch err
        msg = sprintf('Problem during saving of best model file to disk: %s', err.message);
        s.logger.severe(msg);
        printStackTrace(err.stack,s.logger, Level.SEVERE);
    end
end

% update the level plot profiler
if(~isempty(s.levelPlot))
    s.levelPlot = updateLevelPlots(s.levelPlot, model);
end

% Update profiler for best model's model parameters
if(s.samplingEnabled)
    s = observe( s, 'best', size(getSamplesInModelSpace(model),1), model );
else
    s = observe( s, 'best', s.bestModelIndex, model );
end

% add 1 to model counter
s.bestModelIndex = s.bestModelIndex + 1;

%% Determine if this model satisfies the final targets set out by the user
% remember that if you mess with this you must also update rebuildBestModel
% and evaluateMeasure

% we define having reached the targets if every single target is reached
if(all(measureScoreVector <= s.measureData.finalTargets))
        targetsReached = true;
else
        targetsReached = false;
end

% final targets reached, spam only once
if (targetsReached && ~s.finalTargetsReached)
    s.finalTargetsReached = true;
    s.logger.info('');
    s.logger.info('');
    s.logger.info(sprintf('==== FINAL TARGETS REACHED FOR %s ====', arr2str(s.outputNames)));
    s.logger.info('');
end
