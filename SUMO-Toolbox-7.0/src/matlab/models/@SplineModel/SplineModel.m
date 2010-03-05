classdef SplineModel < Model

% SplineModel (SUMO)
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
%	SplineModel(varargin)
%
% Description:
%	Constructs a new Spline model based on the smoothing spline implementation from the Matlab
%	Splines toolbox.  Only works in 2D.

	
	properties(Access = private)
		config;
		spModel;
	end
	
	methods

		function this = SplineModel(varargin)

			if(nargin == 0)
				this.config.smoothing = 0.5;
			elseif(nargin == 1)
				this.config.smoothing = varargin{1};
			else
				error('Invalid number of parameters given');
			end

			this.spModel = [];
		end

		function sm = getSmoothing(this)
			sm = this.config.smoothing;
		end

		function this = setSmoothing(this,sm)
			this.config.smoothing = sm;
		end

		s = constructInModelSpace(s, samples, values);
		[values] = evaluateInModelSpace(s, points);
		desc = getDescription(s);

	end
end
