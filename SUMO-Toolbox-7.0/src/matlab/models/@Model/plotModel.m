function fighandle = plotModel(varargin)

% plotModel (SUMO)
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
%	fighandle = plotModel(varargin)
%
% Description:
%	Plots the model on the given domain (default: [-1 1]). Slice plots are made for dimensions larger than 2.
%	Dimensions higher than 5 are clamped to 0.  Subclasses may override this method if they wish to allow for
%	model specific plotting.  This implementation simply calls basicPlotModel.
%	The default plot options can be found by calling the static member function getPlotDefaults().
%
%	Calling syntax: fighandle = plotModel(model,[output number],[options structure])

[fighandle] = basicPlotModel(varargin{1:nargin});
