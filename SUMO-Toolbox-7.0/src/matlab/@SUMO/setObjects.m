function s = setObjects( s, objects )

% setObjects (SUMO)
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
%	s = setObjects( s, objects )
%
% Description:
%	Plug in all configurable and replaceble components into
%	the toolbox' code.

% Select all objects needed to complete the SUMO object construction
s = setObjectsInternal(s, objects, 'SampleEvaluator', true, false);
s = setObjectsInternal(s, objects, 'AdaptiveModelBuilder', true, true);
s = setObjectsInternal(s, objects, 'SampleSelector', false, true);
s = setObjectsInternal(s, objects, 'LevelPlot', false, true);
s = setObjectsInternal(s, objects, 'InitialDesign', true, true);

%Set the levelplot config on the AMB objects
s = setLevelPlotConfig(s);
