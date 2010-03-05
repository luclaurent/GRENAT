classdef LocalPatternSearch < Optimizer

% LocalPatternSearch (SUMO)
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
% Revision: $Rev$
%
% Signature:
%	LocalPatternSearch(varargin)
%
% Description:
%	Optimizer which generates quasi-latin hypercubes through genetic
%	algorithm optimization.

% private members
	properties (SetAccess = 'private', GetAccess = 'private')
		inDim;
		deviation;
		cornerPointsLeft = 2;
	end
	
	methods
		% constructor
		% Description:
		%     Creates an LHD Optimizer
		function s = LocalPatternSearch(varargin)
			
			% call superclass
			s = s@Optimizer(varargin{:});
			
			% get input dimension
			s.inDim = s.getInputDimension();
			
			% get the fidelity
			config = varargin{1};
			s.deviation = config.self.getDoubleOption('deviation', 0.1);
			
		end
		
		
		function [c, ceq] = unitCircleConstraint(s, x)
			c = sqrt(sum(x.^2, 2)) - 1;
			ceq = [];
		end
		
	end
	
end
