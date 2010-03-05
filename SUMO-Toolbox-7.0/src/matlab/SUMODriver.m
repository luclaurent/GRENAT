function [model, outputDir, errorInfo] = SUMODriver(configFile, samples, values, options, runFilter)

% SUMODriver (SUMO)
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
%	[model, outputDir, errorInfo] = SUMODriver(configFile, samples, values, options, runFilter)
%
% Description:
%	    The main entry point to call the SUMO Toolbox programmatically
%
%	Example:
%	"[surrogateModel outputDir] = SUMODriver('MyConfigFile.xml',xValues, yValues, options, runFilter)"
%
%	With options a cell array containing one or more of:
%	    "-merge" : merge MyConfigFile.xml with the default configuration
%
%	The runFilter parameter is a number or vector (with range [1 numRuns]) that specifies which runs to execute
%
%	NB: the default configuraiton file is /path/to/SUMO/config/default.xml

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read the configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import ibbt.sumo.config.*;
import ibbt.sumo.util.*;
import ibbt.sumo.profiler.*;
import java.util.logging.*;

% Do some input sanity checking
if(ischar(configFile) || isa(configFile,'org.dom4j.tree.DefaultDocument'))
else
    error('The configuration file must be a valid string or a dom4j Document');
end

if(~isa(samples,'double')||~isa(values,'double')|| (size(samples,1) ~= size(values,1)))
    error('The samples and values passed must be valid double arrays with an equal number of rows');
end

if(~iscell(options))
    error('Options must be a cell array');
end

if(isempty(runFilter) || (isa(runFilter,'double') && size(runFilter,1) == 1))
else
    error('The run filter must be a scalar or row vector with elements in [1 numRuns]');
end

model = [];
outputDir = '';
errorInfo = [];

% get location of this file
p = mfilename('fullpath');
% get the toolbox root directory
SUMORoot = p(1:end-22);

try
    %Set the root dir for the rest of the toolbox
    ibbt.sumo.config.ContextConfig.setRootDirectory(SUMORoot);
    
    % does one of the options specify to merge the given config with the default config
    merge = false;
    for i=1:length(options)
        if(strcmp(options{i},'-merge'))
            merge = true;
            break;
        end
    end
    
    if ischar(configFile)
        if merge
            % merge the given file with the default config
            %fullConfig = ConfigUtil.readXML( configFile );
            fullConfig = ConfigUtil.mergeConfigs(fullfile(SUMORoot,'config','default.xml'), configFile);
        else
            % Read the config file
            fullConfig = ConfigUtil.readXML( configFile );
        end
    else
        fullConfig = configFile;
    end
    
    % configure the logger
    ContextConfig.configureLogger(fullConfig);
    
catch err
    if ischar(configFile)
        msg = sprintf( 'Error loading the XML configuration file "%s": %s', configFile, err.message );
    else
        msg = sprintf( 'Error parsing the XML document: %s', err.message );
    end
    
    error(msg);
end

% load the logger
logger = Logger.getLogger('Matlab.SUMODriver');

%% try to configure and run the toolbox
try
    logger.info(sprintf('----------------------------------------------------------------------------------'));
    logger.info(sprintf('----------------------------------------------------------------------------------'));
    logger.info(sprintf('------     _____ __  ____  _______ '));
    logger.info(sprintf('------    / ___// / / /  |/  / __ \\ '));
    logger.info(sprintf('------    \\__ \\/ / / / /|_/ / / / / '));
    logger.info(sprintf('------   ___/ / /_/ / /  / / /_/ / '));
    logger.info(sprintf('------  /____/\\____/_/  /_/\\____/ '));
    logger.info(sprintf('------'));
    logger.info(sprintf('------ Welcome to the SUrrogate MOdeling Toolbox - SUMO Toolbox'));
    logger.info(sprintf('------ '));
    logger.info(sprintf('------ Version: %s',char(ContextConfig.getToolboxVersion())));
    logger.info(sprintf('------ Homepage: %s',char(ContextConfig.getToolboxHomepage())));
    logger.info(sprintf('------ '));
    logger.info(sprintf('------ The SUMO Toolbox is provided "AS IS", without warranty of any kind,'));
    logger.info(sprintf('------ either expressed or implied.'));
    logger.info(sprintf('------ '));
    logger.info(sprintf('------ Please Report all comments, bugs, problems, wishes, ... to:'));
    logger.info(sprintf('------   		<sumo@intec.ugent.be>'));
    logger.info(sprintf('------'));
    logger.info(sprintf('------ Remember that all logging output can be found in the output directory'));
    logger.info(sprintf('----------------------------------------------------------------------------------'));
    logger.info(sprintf('----------------------------------------------------------------------------------'));
    %disp(s);
    
    % print version stuff
    logger.info('System Configuration:');
    logger.info(sprintf(' * Matlab version: %s',version));
    logger.info(sprintf(' * JAVA VM version: %s',version('-java')));
    logger.info(sprintf(' * Operating System: %s', getOS()));
    logger.info(sprintf(' * Platform Architecture: %s', char(java.lang.System.getProperty('os.arch'))));
    logger.info('System Resources:');
    maxmem = floor(java.lang.Runtime.getRuntime.maxMemory/1024^2);
    usedmem = maxmem - floor(java.lang.Runtime.getRuntime.freeMemory/1024^2);
    logger.info(sprintf(' * JVM Memory Usage: %uMB/%uMB', usedmem, maxmem));
    if (maxmem < 256)
        logger.fine('You are running the SUMO toolbox with a java heap size less than 256MB.  This might not be enough for long runs.');
    end
    logger.info(sprintf(' * Maximum number of computational threads: %d', maxNumCompThreads));
    logger.info('');
    
    %Flatten runs that need to be repeated
    fullConfig = ConfigUtil.flattenRuns(fullConfig);
    
    %Get the config valid for all runs
    planConfig = ConfigUtil.getPlanLevelConfig(fullConfig);
    
    % how many runs are there in the plan
    numRuns = ConfigUtil.getNumberOfRuns(fullConfig);
    
    if(numRuns < 1)
        error('The configuration file must contain at least one <Run></Run> tag');
    end
    
    % did the user specifically specify which runs he wants to run
    if(isempty(runFilter))
        runFilter = 1:numRuns;
    else
        if(any(runFilter > numRuns) || any(runFilter < 1))
            msg = sprintf('The run filter contains entries that are out of bounds, must be in [1 %d]',numRuns);
            error(msg);
        else
            logger.info(sprintf('Only running runs %s',arr2str(runFilter)));
            numRuns = length(runFilter);
        end
    end
    
    % loop over all (selected) runs
    for runCtr = runFilter
        runName = '';
        try         
            startRunTime = clock;
            logger.info('');
            logger.info('***');
            logger.info(sprintf('*** Starting run %d of %d at %s',runCtr,length(runFilter),datestr(now,'HH:MM:SS on dd.mm.yy')));
            logger.info('***');
            logger.info('');
            
            % Get the config for this run
            runConfig = ConfigUtil.getRunLevelConfig(fullConfig,runCtr);
            
            % Merge the plan level config with the run level config (run level config overrides plan level config)
            mergedConfig = ConfigUtil.updateConfig(planConfig, runConfig);
            
            % Extract the context configuration, config that every object
            % may need
            context = ContextConfig.getContextConfigInstance(fullConfig, mergedConfig, runCtr);
            
            % Should we enable parallel computing
            if(context.parallelMode())
                enabled = setupParallelMode();
                if(~enabled)
                    context.setParallelMode(false);
                    logger.warning('Parallel mode has been disabled')
                else
                    logger.fine('Parallel mode is successfully enabled');
                end
            end
            
            % Once ContextConfig is constructed the output directory is available
            outputDir = char(context.getOutputDirectory());
            
            % Get the name for this run (with all placeholders replaced)
            runName = char(context.getRunName());
            
            % create config object that wraps all the configuration components
            inputConfig = context.getInputConfig();
            outputConfig = context.getOutputConfig();
            
            config = Config();
            config.context = context;
            config.output = outputConfig;
            config.input = inputConfig;
            config.base = fullConfig;
            
            % configure matlab path for project directory
            % Only used for constraint evaluation at the moment, TODO: constraint
            % evaluation can be better
            projectDirPaths = addpathRecursive( char( config.context.getProjectDirectory() ) );
            
            % construct component struct array for each output
            outputs = outputConfig.getOutputDescriptions();
            outputComponents = struct;
            for j = 1:length(outputs)
                
                % walk each component in the config of this output
                % and add it to the component struct
                
                it = outputs(j).getComponents().iterator();
                outputDesc = sprintf('Output %s configured with components: ', char(outputs(j).getName()));
                while(it.hasNext())
                    entry = ConfigUtil.toNode(it.next());
                    name = char(entry.getName());	%name = AdaptiveModelBuilder, SampleSelector, ...
                    id = char(entry.getText().trim());	 %id = polynomial, default, ....
                    
                    % duplicate definition of this component, error
                    % first output, field doesn't exist
                    if (j == 1 && isfield(outputComponents(j), name)) || (j > 1 && length(outputComponents) == j && ~isempty(outputComponents(j).(name)))
                        msg = sprintf('Component with id "%s" of type "%s" defined a second time with id "%s", this is not allowed', outputComponents(j).(name), name, id);
                        logger.severe(msg);
                        error(msg);
                    end
                    
                    % add component to configuration
                    outputComponents(j).(name) = id;
                    if ~(strcmp(name, 'SUMO') || ...
                            strcmp(name,'ContextConfig') || ...
                            strcmp(name,'Simulator') || ...
                            strcmp(name, 'Outputs') || ...
                            strcmp(name, 'Inputs'))
                        outputDesc = [outputDesc sprintf('[%s=%s] ', name, id)];
                    end
                end
                logger.info(outputDesc);
            end
            
            %Write the config information to the outputdir
            ConfigUtil.writeXML(fullConfig, fullfile(char(context.getOutputDirectory()),'config.xml'));
            
            logger.fine('Creating sub-objects');
            
            %Iterate over the config elements in the run
            objects = struct();
            
            %% walk over all fields in the component array
            componentNames = fieldnames(outputComponents)';
            components = struct;
            for n = componentNames
                name = n{1};
                
                % Ignore the tags that are parsed in advance
                if (strcmp(name,'ContextConfig') || strcmp(name,'Simulator') || strcmp(name, 'Outputs') || strcmp(name, 'Inputs'))
                    continue;
                end
                
                % we filter out auto-sampled inputs for the initial design
                if strcmp(name, 'InitialDesign')
                    filter = [];
                    for i = 0 : inputConfig.getInputDimension()-1
                        if ~inputConfig.getInputDescription(i).isSampledAutomatically()
                            filter = [filter i];
                        end
                    end
                    config.input = FilteredInputConfig(inputConfig, filter);
                else
                    config.input = inputConfig;
                end
                
                logger.fine(sprintf(' - created sub object %s',name));
                
                % get the appropriate config info for each component type,
                % for each output separately (could contain duplicates)
                nodes = {};
                %for ids = {outputComponents.(char(name))}
                for j = 1:length(outputs)
                    id = outputComponents(j).(char(name));
                    %id = ids{1}
                    
                    % id is emtpy - no component of this type specified
                    if isempty(id)
                        msg = sprintf('No component of type "%s" specified for output "%s"', name, char(outputs(j).getName()));
                        logger.severe(msg);
                        error(msg);
                    end
                    
                    % get component data from config
                    newNode = ConfigUtil.resolveReference(fullConfig, name, id);
                    
                    % id not found - error
                    if isempty(newNode)
                        msg = sprintf('No component with id "%s" of type "%s" for output "%s" found in config file', id, name, char(outputs(j).getName()));
                        logger.severe(msg);
                        error(msg);
                    end
                    
                    nodes = [nodes {newNode}];
                end
                
                % combine components & instantiate them
                % now instantiate each component of this type and configure them
                [objects, outputCoverage] = combineComponents(nodes, config);
                
                % component of choice depends on output, add additional info
                components.(char(name)) = struct('objects', {objects}, 'outputCoverage', {outputCoverage});
            end
            
            %% Get the main toolbox object
            hasSUMO = (isfield(components, 'SUMO') && ~isempty(components.SUMO));
            if(~hasSUMO)
                msg = 'No valid SUMO object defined in configuration';
                logger.severe(msg);
                error(msg);
            else
                SUMOobj = components.SUMO.objects{1};
            end
            
            logger.info('Configuring toolbox');
            
            % set the run number of the current plan on all AMB objects
            ambs = components.AdaptiveModelBuilder.objects;
            
            for(i = 1:length(ambs))
                ambs{i} = setRunNumber(ambs{i}, runCtr-1);
            end
            components.AdaptiveModelBuilder.objects = ambs;
            
            % Composes a SUMO object
            SUMOobj = setObjects(SUMOobj, components);
            
            logger.finer('Setting up cleanup object');
            
            % this object ensures all resources are properly cleaned up
            % when the user does a Ctrl-C (eg: close all open files)
            % (see help onCleanup for more info)
            % !!!!! Do not use it for anything else !!!!!
            cleanupObj = onCleanup(@()cleanup(context,SUMOobj));
            
            logger.info('Running toolbox');
            
            % Run the toolbox, passing the given samples and values (possibly empty)
            [SUMOobj, model] = runLoop(SUMOobj, samples, values);
            outputDir = char(config.context.getOutputDirectory());
            
            % ok, the toolbox has finished
            elapsed = etime(clock,startRunTime);
            if elapsed < 180
                logger.info(sprintf('Finished run %d of %d after %d seconds', runCtr, ConfigUtil.getNumberOfRuns(fullConfig), round(elapsed)));
            else
                logger.info(sprintf('Finished run %d of %d after %d minutes', runCtr, ConfigUtil.getNumberOfRuns(fullConfig), round(elapsed/60)));
            end
            
            %% A run is finished, cleanup
            
            % Remove paths of project dir
            rmpath( projectDirPaths );
            
            % Make sure all sample evaluator threads are stopped cleanly
            stopSampleEvaluator(SUMOobj);
            
            % cleanup loggers and profilers
            context.cleanup();
            
            % hint the garbage collector that this is a good time to cleanup
            java.lang.System.gc();
            
        catch ME
            %% Dont let a crash in one run affect the others
            % Make sure all sample evaluator threads are stopped cleanly
            if(exist('SUMOobj','var'))
                stopSampleEvaluator(SUMOobj);
            end
            
            % log the problem
            logError(ME);
            
            if(runCtr ~= numRuns)
                logger.severe(sprintf('An error occurred during run %d of %d (%s), continuing with the next run',runCtr,numRuns,runName));
            end
        end
    end % end of runs
    
    % release any parallel computing resources
    tearDownParallelMode();
    
    % catch errors that occur before the runs have started (context config does
    % not exist yet)
catch ME
    % log the problem
    logError(ME);
    
    % release any parallel computing resources
    tearDownParallelMode();
end

    function logError(err);
        import ibbt.sumo.config.*;
        import java.util.logging.*;
        
        logger = Logger.getLogger('Matlab.SUMODriver');
        
        % log error message
        msg = err.message;
        
        % Make sure the stack trace is always logged!
        l = ibbt.sumo.config.ContextConfig.getMostVerboseLogLevel();
        fineLevel = java.util.logging.Level.FINE;
        if(l > fineLevel.intValue())
            %This means that not a single logging handler will show the stack trace (since all have level > FINE),
            %however, the severe message below, will be shown (if logging is not OFF)
            %This means the user has no way to find out what the exact error was, just that there was an error
            %So now make sure the stack trace is also shown by logging as severe.
            logger.severe( sprintf( 'The following error was caught in SUMODriver: %s', msg ) );
            printStackTrace( err.stack, logger, Level.SEVERE );
        else
            % log stack trace
            l = logger.getLevel();
            if(isempty(l) || l.intValue() > Level.FINE.intValue())
                % this logger has a log level higher than FINE, thus it will not register any fine messages
                % thus to ensure the stack trace is not lost, we log at severe
                logger.severe( sprintf( 'The following error was caught in SUMODriver: %s', msg ) );
                printStackTrace( err.stack, logger, Level.SEVERE );
            else
                % else we log at fine so it does not spam the console, but
                % the user can find it in the logfile
                logger.fine( sprintf( 'The following error was caught in SUMODriver: %s', msg ) );
                printStackTrace( err.stack, logger, Level.FINE );
            end
        end
        errorInfo = err;
        logger.severe('An error occurred, please refer to the log file in the output directory for details');
    end


% This function is ONLY called when the user does Ctrl-C
% do NOT use it for any other cleanup, only put inside what must be
% released on user interupt
    function cleanup(ctxt,sumoObj)
        try
            % close all open Matlab files
            % dangerous to do, closes all files, even those not opened by sumo
            % for example: causes problem with testing framework
            %fclose('all');
            
            % stop all parallel computing nodes
            tearDownParallelMode();
            
            % cleanup loggers and profilers
            ctxt.cleanup();
            
            % stop sample evaluator threads if any
            stopSampleEvaluator(sumoObj);
            
            % hint the garbage collector that this is a good time to cleanup
            java.lang.System.gc();
        catch err
            logError(err);
        end
    end

% end function
end

