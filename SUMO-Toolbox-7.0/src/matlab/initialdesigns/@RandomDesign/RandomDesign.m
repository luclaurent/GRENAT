classdef RandomDesign < InitialDesign

% RandomDesign (SUMO)
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
%	RandomDesign(varargin)
%
% Description:
%	Choose samples randomly

  properties
    points;
  end

  methods
    function this = RandomDesign(varargin)

	  if(nargin == 1)
		config = varargin{1};
		points = config.self.getIntOption('points',50);
		superArgs{1} = config;
      elseif(nargin == 2)
		inDim = varargin{1};
		points = varargin{2};
		superArgs{1} = inDim;
		superArgs{2} = 1;
	  else
		error('Invalid number of arguments');
	  end
	  
	  % construct the base class
      this = this@InitialDesign(superArgs{:});
	  this.points = points;

	end
	
	

    function [initialsamples, evaluatedsamples] = generate(this)
      [inDim outDim] = getDimensions(this);

      % randomly generate a set of points
      initialsamples = rand(this.points, inDim);

      % transform from 0->1 to -1->1
      initialsamples = initialsamples * 2 - 1;

      evaluatedsamples = [];
    end

  end
end
