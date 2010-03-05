function [s] = setLevelPlotConfig(s)

% setLevelPlotConfig (SUMO)
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
%	[s] = setLevelPlotConfig(s)
%
% Description:
%	Set the levelplot config on the AMB objects

if(~isempty(s.levelPlot))
	if(length(s.adaptiveModelBuilder.objects) ~= length(s.levelPlot.objects))
		
		%first check if any of the levelplot objects are actually enabled before giving an error
		enabled = false;
		for i=1:length(s.levelPlot.objects)
			if(isEnabled(s.levelPlot.objects{i}))
				enabled = true;
				break
			end
		end
		
		if(enabled)
			error(sprintf('The number of levelplot objects (%d) does not match the number of adaptive modelbuilder objects (%d), make sure the combineOutputs flag is the same in both components',length(s.levelPlot.objects),length(s.adaptiveModelBuilder.objects)));
		end
	end
	
	for i = 1 : min(length(s.adaptiveModelBuilder.objects),length(s.levelPlot.objects))
		s.adaptiveModelBuilder.objects{i} = setLevelPlotObject(s.adaptiveModelBuilder.objects{i},s.levelPlot.objects{i});
	end
end
