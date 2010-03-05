classdef DataModel < Model

% DataModel (SUMO)
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
%	DataModel(varargin)
%
% Description:
%	Wraps a dataset in a SUMO Model object

	
	properties(Access = private)
	end
	
	methods(Access = public)

		function s = DataModel(varargin)
			% DataModel (SUMO)
			%     Part of the Surrogate Modeling Toolbox ("SUMO Toolbox")
			%     Contributers: W. Hendrickx, D. Gorissen, K. Crombecq, I. Couckuyt, W. van Aarle and T. Dhaene (2005-2009)
			%     Copyright: IBBT - IBCN - UGent
			% Contact : sumo@intec.ugent.be - www.sumo.intec.ugent.be
			%
			% Description:
			%     Wrapper class that wraps a dataset so that it can then be analyzed
			%     using the plot functionality of the toolbox.
			
			% default constructor
			if nargin == 0
				samples = [];
				values = [];
			else
				samples = varargin{1};
				values = varargin{2};
			end

			% calculate dimensions/range
			inDim = size(samples,2);
			outDim = size(values,2);
			inRange = [min(samples, [], 1)' max(samples, [], 1)'];

			% calculate scale/trans values
			minima = inRange(:,1)';
			maxima = inRange(:,2)';
			translate = (maxima+minima) ./ 2.0;
			scale = (maxima-minima) ./2.0;
			
			% calculate transformation functions
			[inFunc, outFunc] = calculateTransformationFunctions([translate ; scale]);

			% create class
			s@Model(inDim, outDim, inFunc(samples), values);
			
			% set the transformation values
			s = setTransformationValues(s, [translate ; scale]);
		end
	end
end

