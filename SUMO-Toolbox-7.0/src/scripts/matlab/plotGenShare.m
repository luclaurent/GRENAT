function plotGenShare(data,types)

% plotGenShare (SUMO)
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
%	plotGenShare(data,types)
%
% Description:
%	Plot the data in a gen_share profiler data file.  Data can be a filename or raw matrix

if(ischar(data))
  d = load(data);
else
  % assume matrix of data
end

plotColumns(d);
legend(types,'Location','NorthEastOutside','FontSize',14,'interpreter','none');
ylabel(['Number of models'],'FontSize',14,'interpreter','none');
xlabel('Generation','FontSize',14,'interpreter','none');
set(gca,'FontSize',14);
set(gca,'YScale','linear');
