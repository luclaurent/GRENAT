function [data] = plotMeasureProfilers(directory, runMask, errorFcn, saveData);

% plotMeasureProfilers (SUMO)
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
%	[data] = plotMeasureProfilers(directory, runMask, errorFcn, saveData);
%
% Description:
%	Generate plots of all the measure profilers from the runs that match the regexp runMask in the given directory
%	Requires xticklabel_rotate from Matlab central

if(~exist('runMask'))
	runMask = '.*';
end

if(~exist('errorFcn'))
	errorFcn = '.*';
end

if(~exist('saveData'))
	saveData = false;
end

profilerMask = ['Measure_.*' errorFcn '.*'];

data = groupProfilerData(directory,runMask,profilerMask);
names = fieldnames(data);

shapeGrid = buildShapeGrid();
nShapes = length(shapeGrid);

for i=1:length(names)

	n = names{i};
	p = data.(n);
	
  	%Plot the final results as a piecewise line %bar chart
  	figure
  	%bar(p.final(:,2:end))
    plot( p.final(:,2:end), 'x' )
    
  	xlabel('Run','FontSize',14,'interpreter','none');
  	ylabel(n,'FontSize',14,'interpreter','none')
  	xticklabel_rotate(1:length(p.runNames),90,p.runNames,'interpreter','none');

	%show the avg and std as part of the title
	title({['avg: ' arr2str(p.finalAvg(2:end))],['std: ' arr2str(p.finalStd(2:end))]},'FontSize',14,'interpreter','none');
	set(gca,'YScale','log');
    
    if saveData
        tmp = p.final;
        save( [n '_bestScores.txt'], 'tmp', '-ascii' );
    end

	%Plot the evolution of the error
	figure;
	d = [];
	for j=1:length(p.data)
		%build the line style
		si = mod(j,nShapes)+1;
		shape = shapeGrid{si};

		d = p.data{j};

		plot(d(:,1),d(:,2),shape)
		hold on;
	end
	hold off
	xlabel('Number of samples / Best model number','FontSize',14,'interpreter','none');
	ylabel(n,'FontSize',14,'interpreter','none');
	legend(p.runNames,'FontSize',14,'Location','NorthEastOutside','interpreter','none');

	%Plot the average evolution of the error
	figure;
	errorbar(p.meanData(:,1),p.meanData(:,2), p.stdData(:,2));
	hold off
	xlabel('Number of samples / Best model number','FontSize',14,'interpreter','none');
	ylabel([n ' - average'],'FontSize',14,'interpreter','none');
	legend(p.runNames,'FontSize',14,'Location','NorthEastOutside','interpreter','none');


	%show the avg and std as part of the title
	title({['avg: ' arr2str(p.finalAvg(2:end))],['std: ' arr2str(p.finalStd(2:end))]},'FontSize',14,'interpreter','none');

	set(gca,'YScale','log');
end
