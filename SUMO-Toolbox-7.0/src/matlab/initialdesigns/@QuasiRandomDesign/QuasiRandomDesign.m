classdef QuasiRandomDesign < InitialDesign

% QuasiRandomDesign (SUMO)
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
%	QuasiRandomDesign(varargin)
%
% Description:
%	Generates a space-filling initial design by generating the first of a
%	set of quasi-random numbers.

  properties
	  points;
	  design;
	  designType;
  end

  methods
    function this = QuasiRandomDesign(varargin)
      import java.util.logging.Logger;

      % we first have to ensure we can construct the base class
      if(nargin == 1)
		  
		  % config
		config = varargin{1};
		superArgs{1} = config;
		
		% get info
		inDim = config.input.getInputDimension();
		points = config.self.getIntOption('points',10*inDim+1);
		designType = char(config.self.getOption('type', 'sobol'));
		
      elseif(nargin == 2)
		  
		  % super args
		inDim = varargin{1};
		points = varargin{2};
		superArgs{1} = inDim;
		superArgs{2} = 1;
		designType = 'sobol';
	  else
		error('Invalid number of parameters given');
      end

      % construct the base class
      this = this@InitialDesign(superArgs{:});
	  
	  % set obj
	  this.points = points;
	  this.designType = designType;
	  if ~strcmp(this.designType, 'hammersley')
		 this.design = qrandstream(designType, inDim);
	  end
    end

    [initialsamples, evaluatedsamples] = generate(this);

  end
end
