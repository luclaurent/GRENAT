function summarizeRuns( directory, runMask, output )

% summarizeRuns (SUMO)
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
%	summarizeRuns( directory, runMask, output )
%
% Description:
%	   A helper file to collect and plot results of different runs with multiple replicates
%	Parameters:
%	   directory: where the runs can be found
%	   runMask: a cell array with runMasks (e.g., {'.*hetero.*'}}, plots will be grouped by each mask
%	   output: output name

if(~exist('runMask'))
	runMask = '.*';
end

% type/error fcn used of/by the driving measure (change to suit your results)
errorFcn = 'rootRelativeSquareError';
type ='ValidationSet';
%errorFcn = 'rootRelativeSquareError';
%type ='CrossValidation';
heteroLegend = {'Ensemble','LS-SVM','Rational','Kriging','ANN'};

% group all profilers
profilerMask = '.*';

for r=1:length(runMask)
	rm = runMask{r};

	disp(['*Grouping data for ' rm]);

	data = groupProfilerData(directory, rm, profilerMask);
	
	% data now contains all the results of the replicates of a given run
	% grouped by profiler name
	% Now we can actully do something with this data

	% for example....

  	% plot the total running time
  	%plotRunningTime(data,output);

	% plot the final number of samples used
	%plotFinalNumSamples(data,output);

  	% plot the final number of free parameters
	% plotFinalFreeParam(data,output);

	% plot the final data of a particular measure
  	%plotFinalMeasureData(data,output);

	% plot the evolution of the measure used to drive the modeling
	%plotMeasureEvolution(data,output);

	% plot the final levelplot makeup
	%plotFinalLevelPlot(data,output);

	% re-create the levelplots (so we can save them nicely in eps)
	replotLevelPlots(data,output);

	% plot the final population makeup of a number of heterogenetic replicates
	%plotFinalGenShare(data,output);

	% re-create the gen share plots
	%replotGenShare(data,output);
end


	function plotRunningTime(data,output)
		%get the relevant profiler
		profName = ['ElapsedTimeProfiler_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		lpdata = profData.final(:,2:end);
		bar(1:size(lpdata,1),lpdata,'stacked');
		ylabel(['Elapsed time (min) (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', profName);
		set(gca,'FontSize',14);
		
		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(2:end))],['std: ' arr2str(profData.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	end

	function plotFinalNumSamples(data,output)
		%get the relevant profiler
		profName = ['LevelPlotProfiler_' output]; %use the lp profiler for sample data
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		lpdata = profData.final(:,1);
		bar(1:size(lpdata,1),lpdata,'stacked');
		ylabel(['Number of samples / Iterations (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', 'Number of samples / Iterations');
		set(gca,'FontSize',14);
		
		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(1))],['std: ' arr2str(profData.finalStd(1))]},'FontSize',14,'interpreter','none');
    end

	function plotFinalFreeParam(data,output)
		%get the relevant profiler
		profName = ['FreeParamProfiler_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		mdata = profData.final(:,2:end);
		bar(1:size(mdata,1),mdata);
		ylabel(['Free parameters (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', [errorFcn ' (' output ')']);
		set(gca,'FontSize',14);
		
		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(2:end))],['std: ' arr2str(profData.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	end


	function plotFinalMeasureData(data,output)
		%get the relevant profiler
		profName = ['Measure_' output '_' type '_' errorFcn];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		lpdata = profData.final(:,2);
		bar(1:size(lpdata,1),lpdata,'stacked');
		ylabel(['Final ' errorFcn ' (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', 'Final Measure score');
		set(gca,'FontSize',14);
		
		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(2))],['std: ' arr2str(profData.finalStd(2))]},'FontSize',14,'interpreter','none');
	end

	function plotMeasureEvolution(data,output)
		%get the relevant profiler
		profName = ['Measure_' output '_' type '_' errorFcn];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);

		%Create all possible line styles
		co = {'b','g','r','c','m','k'};
		sh = {'d','.','s','o','x','*','v','+'};
		li = {'-',':','-.'};
		shapeGrid = makeEvalGrid({1:length(sh), 1:length(co), 1:length(li)});

		%create and show the figure
		figure;
		mdata = profData.data;
		for j=1:length(mdata)
			%build the line style
			si = mod(j,length(shapeGrid));
			if(si == 0); si = length(shapeGrid); end
			shape = sprintf('%s%s%s',co{shapeGrid(si,2)},sh{shapeGrid(si,1)},li{shapeGrid(si,3)});

			d = mdata{j};
			plot(d(:,1),d(:,2),shape);
			hold on
		end
		hold off;
			
		%build the legend
		for i=1:length(mdata); leg{i} = ['Rep ' num2str(i)]; end 	
		legend(leg,'FontSize',14,'interpreter','none');

		ylabel([errorFcn ' (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of samples / Iterations','FontSize',14,'interpreter','none');
		set(gcf,'Name', [errorFcn ' (' output ')']);
		set(gca,'FontSize',14);
		
		%show the avg and std as part of the title
		title({['final avg: ' arr2str(profData.finalAvg(2:end))],['final std: ' arr2str(profData.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	
		%set in log scale
		set(gca,'YScale','log');
	end

	function plotFinalLevelPlot(data,output)
		%get the relevant profiler
		profName = ['LevelPlotProfiler_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		lpdata = profData.final(:,2:end);
		bar(1:size(lpdata,1),lpdata,'stacked');
		colormap gray
		legend({'e >= 1e0','1e0 > e >= 1e-1','1.e-1 > e >= 1e-2','1e-2 > e >= 1e-3','1.e-3 > e >= 1e-4','e < 1e-4'},'Location','NorthEastOutside','FontSize',14,'interpreter','none');
		ylabel(['Percentage of test samples (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', profName);
		set(gca,'FontSize',14);
		set(gca,'YLim',[0 102]);

		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(2:end))],['std: ' arr2str(profData.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	end

	function replotLevelPlots(data,output)
		%get the relevant profiler
		profName = ['LevelPlotProfiler_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure for each replicate
		for i=1:length(profData.data)
			lpdata = profData.data{i};
			figure;
			area(lpdata(:,1),lpdata(:,2:end));
			colormap gray
			legend({'e >= 1e0','1e0 > e >= 1e-1','1.e-1 > e >= 1e-2','1e-2 > e >= 1e-3','1.e-3 > e >= 1e-4','e < 1e-4'},'Location','NorthEastOutside','FontSize',14,'interpreter','none');
			ylabel(['Percentage of test samples (' output ')'],'FontSize',14,'interpreter','none');
			xlabel('Number of samples / Iteration','FontSize',14,'interpreter','none');
			set(gcf,'Name', [profName '_rep' num2str(i)]);
			set(gca,'FontSize',14);
			set(gca,'YLim',[0 100]);
		end
	end

	function replotGenShare(data,output)
		%get the relevant profiler
		profName = ['gen_share_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure for each replicate
		for i=1:length(profData.data)
			lpdata = profData.data{i};
			figure;
			plotColumns(lpdata);
			legend(heteroLegend,'Location','NorthEastOutside','FontSize',14,'interpreter','none');
			ylabel(['Number of models (' output ')'],'FontSize',14,'interpreter','none');
			xlabel('Generation','FontSize',14,'interpreter','none');
			set(gcf,'Name', [profName '_rep' num2str(i)]);
			set(gca,'FontSize',14);
			set(gca,'YScale','linear');
		end
	end

	function plotFinalGenShare(data,output)
		%get the relevant profiler
		profName = ['gen_share_' output];
		if(~isfield(data,profName)); return; end;
		profData = getfield(data,profName);
		
		%create and show the figure
		figure;
		finalHetero = profData.final(:,2:end);
		bar(1:size(finalHetero,1),finalHetero,'stacked');
		colormap gray
		legend(heteroLegend,'Location','NorthEastOutside','FontSize',14,'interpreter','none');
		ylabel(['Number of models (' output ')'],'FontSize',14,'interpreter','none');
		xlabel('Number of runs','FontSize',14,'interpreter','none');
		set(gcf,'Name', profName);
		set(gca,'FontSize',14);

		%show the avg and std as part of the title
		title({['avg: ' arr2str(profData.finalAvg(2:end))],['std: ' arr2str(profData.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	end
end
