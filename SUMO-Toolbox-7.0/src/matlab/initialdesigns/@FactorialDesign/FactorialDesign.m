classdef FactorialDesign < InitialDesign

% FactorialDesign (SUMO)
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
%	FactorialDesign(varargin)
%
% Description:
%	Factorial design

  properties
    levels;
    logger;
  end

  methods
    function this = FactorialDesign(varargin)

      if(nargin == 1)
		config = varargin{1};
		levels = str2num( config.self.getOption( 'levels', '5' ) );
		superArgs{1} = config;
      elseif(nargin == 2)
		inDim = varargin{1};
		levels = varargin{2};
		superArgs{1} = inDim;
		superArgs{2} = 1;
	  else
		error('Invalid number of arguments');
      end

      % construct the base class
      this = this@InitialDesign(superArgs{:});

      [in out] = this.getDimensions();

      import java.util.logging.*
      this.logger = Logger.getLogger('Matlab.FactorialDesign');

      if isscalar( levels )
	levels = repmat( levels, 1, in );
      end
      
      if size( levels, 2 ) ~= in
	      error('Length of levels vector must be equal to the input dimension.');
      end

      this.levels = levels;
    end

    [initialsamples, evaluatedsamples] = generate(this);

  end
end
