function groupMeasures(groups, directory, profilerMask )

% groupMeasures (SUMO)
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
%	groupMeasures(groups, directory, profilerMask )
%
% Description:
%	   A helper file to summarize a set of runs where each run consists of multiple repetitions.
%	In this case the average over the measure scores of each group (=set of repetitions of one run) is taken and plotted
%	For example groups could be: {'.*cmaes.*','.*diffevol.*','.*direct.*'} if you want to average over 3 sets of runs each with a different
%	number of repetitions.

if(~exist('profilerMask','var'))
    errorFcn = 'rootRelativeSquareError';
    type = 'ValidationSet';
    profilerMask = ['Measure_.*_' type '_' errorFcn];
else
end

shapeGrid = buildShapeGrid();

for i=1:length(groups)
    runMask = groups{i};
    data = groupProfilerData(directory,runMask,profilerMask);
    names = fieldnames(data);

    if(isempty(names))
        continue;
    end
    
    n = names{1};
    p = data.(n);

    %build the line style
    si = mod(i,length(shapeGrid))+1;
    shape = shapeGrid{si};

    d = p.data{1};

    %Plot the average evolution of the error
    %errorbar(p.meanData(:,1),p.meanData(:,2), p.stdData(:,2),shape);
    plot(p.meanData(:,1),p.meanData(:,2),shape);

    hold on
end

hold off
xlabel('Number of samples / Best model number','FontSize',14,'interpreter','none');
ylabel([n ' - average'],'FontSize',14,'interpreter','none');
legend(groups,'FontSize',14,'Location','NorthEastOutside','interpreter','none');

%set(gca,'YScale','log');
