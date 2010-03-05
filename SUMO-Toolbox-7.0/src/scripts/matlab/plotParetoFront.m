function h = plotParetoFront(scores, labels)

% plotParetoFront (SUMO)
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
%	h = plotParetoFront(scores, labels)
%
% Description:
%	plots 2 column vector as a front, and annotate it a bit

[minscores minidx] = min(scores);
[maxscores maxidx] = max(scores);

% plot
plot( scores(:,1), scores(:,2), 'x' );
hold on;

% annotate
middle = 14; % hardcoded for SWAT (loge vs efficiency)
bounds = [scores(minidx(1),:) ; scores(maxidx(2),:) ; scores(middle,:) ];

scatter(bounds(:,1), bounds(:,2), 100, 'o', 'MarkerEdgeColor', 'k');
bounds % user has to draw text himself...

% plot options for niceness
set(gca, 'FontSize',14 )

%title('Error evolution', 'FontSize',14,'interpreter','none');
set(gca, 'XTick', linspace( minscores(1), maxscores(1), 5 ) )
set(gca, 'YTick', linspace( minscores(2), maxscores(2), 10 ) )

xlabel( labels{1}, 'FontSize', 14);
ylabel( labels{2}, 'FontSize', 14);

