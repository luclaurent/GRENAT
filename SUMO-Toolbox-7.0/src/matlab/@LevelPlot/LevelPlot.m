classdef LevelPlot

% LevelPlot (SUMO)
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
%	LevelPlot(config)
%
% Description:
%	The class holds the data necessary to generate LevelPlots.  These are stacked area plots that plot the accuracy
%	histogram of a surrogate model in funciton of the number of samples (or modeling iteration).
%	Each level plot object contains a profiler object which is responsible for the actual plot generation.

  properties(Access = private)
      makeLevelPlots = false;
      levelPlotSamples = 0;
      levelPlotValues = 0;
      ticks = 0;
      tickLabels = 0;
      nTicks = 0;
      logger = 0;
      errorFcn = 0;
      counter = 1;
      samplingEnabled = 0;
      sampleEvaluator = [];
      profilers = {};
    end

  methods
    function this = LevelPlot(config)
      import ibbt.sumo.profiler.*;
      import java.util.logging.*

      logger = Logger.getLogger('Matlab.LevelPlot');

      sampleManager = SampleManager(config);

      makeLevelPlots = config.self.getBooleanOption('makeLevelPlots',0);
      samplingEnabled = config.context.samplingEnabled();

      if(~makeLevelPlots)
	% nothing to do, levelplot generation switched off
      else
	  %The default error function is the standard relative error
	  errorFcn = str2func(char(config.self.getAttrValue('errorFcn','relativeError')));
	  logger.info(sprintf('Level plots switched on with %s error function',func2str(errorFcn)));

	  % Get the sampleevaluator where we should extract our reference points from
	  logger.fine('Creating level plot SampleEvaluator');
	  node = config.self.selectSingleNode('SampleEvaluator');
	  if isempty(node)
		  msg = '`makeLevelPlots'' is switched on, please specify a `SampleEvaluator''';
		  logger.severe(msg);
		  error(msg);
	  end
	  lpSE = instantiate(node, config);

	  % Extract all sample data from SampleSource
	  logger.finer('Extracting all sample points for the level plots');

	  [levelPlotSamples, levelPlotValues] = extractRawDataset(lpSE.getData());
	  sampleManager = add(sampleManager, levelPlotSamples, levelPlotValues);
	  [levelPlotSamples, levelPlotValues] = getInModelSpace(sampleManager);

	  % Extract profiler `ticks', i.e. bounds in which the samples are grouped
	  tryTicks = str2num(char(config.self.getOption('ticks', '')));
	  tryTickLabels = stringSplit(char(config.self.getOption('tickLabels', '')), ',');
	  
	  if isempty( tryTicks )
		  ticks = [1 .1 .01 .001 .0001];
		  tickLabels = {'1','1E-1','1E-2','1E-3','1E-4'};
	  else 
		  ticks = tryTicks;
		  tickLabels = iff( isempty( tryTickLabels ), stringSplit( num2str( ticks ), ' ' ), tryTickLabels );
	  end
	  nTicks = length(ticks);
	  
	  if length( tickLabels ) ~= nTicks
		  msg = 'LevelPlotTickLabels length does not match number of ticks!';
		  s.logger.warning( msg );
		  tickLabels = stringSplit( num2str( ticks ), ' ' );
	  end
	  
	  % construct a separate profiler for each output (happens if combineOutputs == true)
	  % note: the combineOutputs flag for the levelplot and modelbuilder should always be the same
	  numOut = size(levelPlotValues,2);
	  levelPlotProfilers = cell(1,numOut);
	  for(k=1:numOut)
		  profilerID = [char(config.output.getOutputName(k-1))];
		  profname = ['LevelPlotProfiler_' profilerID];
		  profname = ProfilerManager.makeUniqueProfilerName(profname);
		  prof = ProfilerManager.getProfiler(profname);
		  prof.setDescription(['Error histogram evolution (' func2str(errorFcn) ')']);

		  if(samplingEnabled)
			  prof.addColumn('sampleSize', 'Number of samples used');
		  else
			  prof.addColumn('iteration', 'New best model number');
		  end
	  
		  short = sprintf( 'x >= %s', tickLabels{1} );
		  desc = sprintf( 'e >= %f', ticks(1) );
		  prof.addColumn(short,desc);
		  for i = 2:1:nTicks
			  short = sprintf('%s > x >= %s', tickLabels{i-1}, tickLabels{i} );
			  desc = sprintf('%f > e >= %f', ticks(i-1), ticks(i) );
			  prof.addColumn(short,desc);
		  end
		  short = sprintf( 'x < %s', tickLabels{end} );
		  desc = sprintf( 'e < %f', ticks(nTicks) );
		  prof.addColumn(short,desc);
		  prof.setPreferredChartType(ChartType.LEVEL);

		  levelPlotProfilers{k} = prof;
	      end
	      
	      logger.finer(sprintf('Created %d levelplot profiler objects',numOut))

	      this.counter = 1;
	      this.errorFcn = errorFcn;
	      this.makeLevelPlots = makeLevelPlots;
	      this.samplingEnabled = samplingEnabled;
	      this.sampleEvaluator = lpSE;
	      this.profilers =  levelPlotProfilers;
	      this.levelPlotSamples =  levelPlotSamples;
	      this.levelPlotValues =  levelPlotValues;
	      this.ticks =  ticks;
	      this.tickLabels =  tickLabels;
	      this.nTicks =  nTicks;
	      this.logger =  logger;
	end % end if
    end % constructor

    function res = isEnabled( this )
      res = this.makeLevelPlots;
    end

    this = updateLevelPlots( this, model );

  end % methods
end % classdef
